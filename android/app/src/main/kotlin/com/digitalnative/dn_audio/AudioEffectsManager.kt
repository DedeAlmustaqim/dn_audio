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
    private val initializationErrors = mutableMapOf<String, String>()

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
            initializationErrors.clear()
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
            mapOf(
                "supported" to false,
                "error" to (initializationErrors["equalizer"] ?: "effect_unavailable")
            )
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
                        "maxFrequencyHz" to frequencyRange[1] / 1000,
                        "levelMillibels" to eq.getBandLevel(band).toInt()
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
            mapOf(
                "supported" to false,
                "error" to (initializationErrors["bassBoost"] ?: "effect_unavailable")
            )
        } else {
            try {
                mapOf(
                    "supported" to true,
                    "enabled" to bass.enabled,
                    "strengthSupported" to bass.strengthSupported,
                    "minStrength" to 0,
                    "maxStrength" to 1000,
                    "strength" to bass.roundedStrength.toInt()
                )
            } catch (error: Exception) {
                mapOf(
                    "supported" to false,
                    "error" to error.javaClass.simpleName
                )
            }
        }

        val virtualizerInfo = if (virtual == null) {
            mapOf(
                "supported" to false,
                "error" to (initializationErrors["virtualizer"] ?: "effect_unavailable")
            )
        } else {
            try {
                mapOf(
                    "supported" to true,
                    "enabled" to virtual.enabled,
                    "strengthSupported" to virtual.strengthSupported,
                    "minStrength" to 0,
                    "maxStrength" to 1000,
                    "strength" to virtual.roundedStrength.toInt()
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
            "error" to if (eq == null && bass == null && virtual == null) "no_supported_effects" else null,
            "equalizer" to equalizerInfo,
            "bassBoost" to bassInfo,
            "virtualizer" to virtualizerInfo
        )
    }

    @Synchronized
    fun setEqualizerEnabled(enabled: Boolean): Map<String, Any?> {
        val effect = equalizer ?: return equalizerOperationFailure("equalizer_unavailable")
        return try {
            effect.enabled = enabled
            equalizerOperationSuccess()
        } catch (error: Exception) {
            equalizerOperationFailure(error.javaClass.simpleName)
        }
    }

    @Synchronized
    fun setBandLevel(bandIndex: Int, levelMillibels: Int): Map<String, Any?> {
        val effect = equalizer ?: return equalizerOperationFailure("equalizer_unavailable")
        return try {
            if (bandIndex !in 0 until effect.numberOfBands.toInt()) {
                return equalizerOperationFailure("invalid_band_index")
            }

            val range = effect.bandLevelRange
            if (levelMillibels < range[0].toInt() || levelMillibels > range[1].toInt()) {
                return equalizerOperationFailure("level_out_of_range")
            }

            effect.setBandLevel(bandIndex.toShort(), levelMillibels.toShort())
            equalizerOperationSuccess()
        } catch (error: Exception) {
            equalizerOperationFailure(error.javaClass.simpleName)
        }
    }

    @Synchronized
    fun setBassBoost(enabled: Boolean, strength: Int): Map<String, Any?> {
        val effect = bassBoost ?: return effectOperationFailure("bassBoost", "effect_unavailable")
        return try {
            if (strength !in 0..1000) {
                return effectOperationFailure("bassBoost", "strength_out_of_range")
            }
            if (effect.strengthSupported) {
                // Android's setStrength() returns Unit; failures are surfaced as exceptions.
                effect.setStrength(strength.toShort())
            }
            effect.enabled = enabled
            effectOperationSuccess()
        } catch (error: Exception) {
            effectOperationFailure("bassBoost", error.javaClass.simpleName)
        }
    }

    @Synchronized
    fun setVirtualizer(enabled: Boolean, strength: Int): Map<String, Any?> {
        val effect = virtualizer ?: return effectOperationFailure("virtualizer", "effect_unavailable")
        return try {
            if (strength !in 0..1000) {
                return effectOperationFailure("virtualizer", "strength_out_of_range")
            }
            if (effect.strengthSupported) {
                // Android's setStrength() returns Unit; failures are surfaced as exceptions.
                effect.setStrength(strength.toShort())
            }
            effect.enabled = enabled
            effectOperationSuccess()
        } catch (error: Exception) {
            effectOperationFailure("virtualizer", error.javaClass.simpleName)
        }
    }

    private fun effectOperationSuccess(): Map<String, Any?> = mapOf(
        "success" to true,
        "capabilities" to getCapabilities()
    )

    private fun effectOperationFailure(effect: String, error: String): Map<String, Any?> = mapOf(
        "success" to false,
        "effect" to effect,
        "error" to error,
        "capabilities" to getCapabilities()
    )

    private fun equalizerOperationSuccess(): Map<String, Any?> = mapOf(
        "success" to true,
        "capabilities" to getCapabilities()
    )

    private fun equalizerOperationFailure(error: String): Map<String, Any?> = mapOf(
        "success" to false,
        "error" to error,
        "capabilities" to getCapabilities()
    )

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
        initializationErrors.clear()
    }

    private fun releaseSafely(effect: AudioEffect?) {
        try {
            effect?.release()
        } catch (_: Exception) {
            // Releasing an optional effect must remain best-effort.
        }
    }

    private fun <T : AudioEffect> createEffect(
        effectName: String,
        factory: () -> T
    ): T? {
        val effect = try {
            factory()
        } catch (error: Exception) {
            initializationErrors[effectName] = error.javaClass.simpleName
            return null
        }

        return try {
            effect.enabled = false
            effect
        } catch (error: Exception) {
            initializationErrors[effectName] = error.javaClass.simpleName
            releaseSafely(effect)
            null
        }
    }
}
