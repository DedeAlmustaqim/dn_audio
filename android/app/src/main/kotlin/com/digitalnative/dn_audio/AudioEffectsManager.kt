package com.digitalnative.dn_audio

import android.media.audiofx.AudioEffect
import android.media.audiofx.BassBoost
import android.media.audiofx.Equalizer
import android.media.audiofx.Virtualizer

/**
 * Owns Android audio-effect instances for one player audio session.
 *
 * Effects are optional: failure to create one effect must not prevent the
 * other effects from being discovered or used.
 */
class AudioEffectsManager {
    private var attachedSessionId: Int? = null
    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null
    private var virtualizer: Virtualizer? = null

    @Synchronized
    fun attachSession(sessionId: Int): Map<String, Any?> {
        if (sessionId <= 0) {
            release()
            return mapOf(
                "available" to false,
                "sessionId" to null,
                "error" to "invalid_session_id"
            )
        }

        if (attachedSessionId != sessionId) {
            releaseEffects()
            attachedSessionId = sessionId
            equalizer = createEffect("equalizer") { Equalizer(0, sessionId) }
            bassBoost = createEffect("bassBoost") { BassBoost(0, sessionId) }
            virtualizer = createEffect("virtualizer") { Virtualizer(0, sessionId) }
        }

        return getCapabilities()
    }

    @Synchronized
    fun getCapabilities(): Map<String, Any?> {
        val eq = equalizer
        val bass = bassBoost
        val virtual = virtualizer

        val equalizerInfo = if (eq == null) {
            mapOf("supported" to false)
        } else {
            try {
                val bandRange = eq.bandLevelRange
                val bands = (0 until eq.numberOfBands.toInt()).map { index ->
                    val band = index.toShort()
                    val frequencyRange = eq.getBandFreqRange(band)
                    mapOf(
                        "index" to index,
                        "centerFrequencyHz" to eq.getCenterFreq(band) / 1000,
                        "minFrequencyHz" to frequencyRange[0] / 1000,
                        "maxFrequencyHz" to frequencyRange[1] / 1000
                    )
                }
                mapOf(
                    "supported" to true,
                    "enabled" to eq.enabled,
                    "bandCount" to eq.numberOfBands.toInt(),
                    "minLevelMillibels" to bandRange[0].toInt(),
                    "maxLevelMillibels" to bandRange[1].toInt(),
                    "bands" to bands,
                    "presetCount" to eq.numberOfPresets.toInt()
                )
            } catch (error: Exception) {
                mapOf(
                    "supported" to false,
                    "error" to error.javaClass.simpleName
                )
            }
        }

        val bassInfo = if (bass == null) {
            mapOf("supported" to false)
        } else {
            try {
                mapOf(
                    "supported" to true,
                    "enabled" to bass.enabled,
                    "strengthSupported" to bass.strengthSupported,
                    "minStrength" to 0,
                    "maxStrength" to 1000
                )
            } catch (error: Exception) {
                mapOf(
                    "supported" to false,
                    "error" to error.javaClass.simpleName
                )
            }
        }

        val virtualizerInfo = if (virtual == null) {
            mapOf("supported" to false)
        } else {
            try {
                mapOf(
                    "supported" to true,
                    "enabled" to virtual.enabled,
                    "strengthSupported" to virtual.strengthSupported,
                    "minStrength" to 0,
                    "maxStrength" to 1000
                )
            } catch (error: Exception) {
                mapOf(
                    "supported" to false,
                    "error" to error.javaClass.simpleName
                )
            }
        }

        return mapOf(
            "available" to (eq != null || bass != null || virtual != null),
            "sessionId" to attachedSessionId,
            "equalizer" to equalizerInfo,
            "bassBoost" to bassInfo,
            "virtualizer" to virtualizerInfo
        )
    }

    @Synchronized
    fun release() {
        releaseEffects()
        attachedSessionId = null
    }

    private fun releaseEffects() {
        releaseSafely(equalizer)
        releaseSafely(bassBoost)
        releaseSafely(virtualizer)
        equalizer = null
        bassBoost = null
        virtualizer = null
    }

    private fun releaseSafely(effect: AudioEffect?) {
        try {
            effect?.release()
        } catch (_: Exception) {
            // Releasing an optional effect must remain best-effort.
        }
    }

    private fun <T : AudioEffect> createEffect(
        name: String,
        factory: () -> T
    ): T? {
        return try {
            factory().also { effect ->
                effect.enabled = false
            }
        } catch (_: Exception) {
            null
        }
    }
}
