import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../models/audio_effects_capabilities.dart';
import '../services/dn_audio_handler.dart';

class EqualizerView extends StatefulWidget {
  const EqualizerView({super.key});

  @override
  State<EqualizerView> createState() => _EqualizerViewState();
}

class _EqualizerViewState extends State<EqualizerView> {
  late final DnAudioHandler _handler;
  final Map<int, double> _draftLevels = {};
  bool _isRefreshing = false;
  bool _isToggling = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _handler = Get.find<DnAudioHandler>();
    _refreshCapabilities();
  }

  Future<void> _refreshCapabilities() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _handler.audioEffectsService.getCapabilities();
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _toggleEqualizer(bool enabled) async {
    if (_isToggling) return;
    setState(() {
      _isToggling = true;
      _message = null;
    });
    final success =
        await _handler.audioEffectsService.setEqualizerEnabled(enabled);
    if (!mounted) return;
    setState(() {
      _isToggling = false;
      if (!success) {
        _message = 'Pengaturan Equalizer gagal diterapkan.';
      }
    });
  }

  Future<void> _applyBandLevel(int index, double value) async {
    final success = await _handler.audioEffectsService.setBandLevel(
      index,
      value.round(),
    );
    if (!mounted) return;
    setState(() {
      _draftLevels.remove(index);
      _message = success ? null : 'Level band gagal diterapkan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = _handler.audioEffectsService;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.84,
        child: StreamBuilder<AudioEffectsCapabilities>(
          stream: service.capabilitiesStream,
          initialData: service.capabilities,
          builder: (context, snapshot) {
            final capabilities = snapshot.data ?? service.capabilities;
            final equalizer = capabilities.equalizer;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 16, 12),
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EQUALIZER',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Sound control',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Refresh capability',
                            onPressed:
                                _isRefreshing ? null : _refreshCapabilities,
                            icon: _isRefreshing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border, height: 1),
                Expanded(
                  child: _buildContent(capabilities, equalizer),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    AudioEffectsCapabilities capabilities,
    AudioEffectCapability equalizer,
  ) {
    if (!capabilities.available || !equalizer.supported) {
      return _UnavailableState(
        message: capabilities.error ??
            equalizer.error ??
            'Equalizer belum tersedia pada sesi audio ini.',
        onRefresh: _refreshCapabilities,
        isRefreshing: _isRefreshing,
      );
    }

    if (equalizer.bands.isEmpty) {
      return _UnavailableState(
        message: 'Perangkat tidak melaporkan konfigurasi band Equalizer.',
        onRefresh: _refreshCapabilities,
        isRefreshing: _isRefreshing,
      );
    }

    final minLevel = (equalizer.minLevelMillibels ?? -1500).toDouble();
    final maxLevel = (equalizer.maxLevelMillibels ?? 1500).toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Equalizer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Enable audio frequency control',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isToggling)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch.adaptive(
                  value: equalizer.enabled,
                  activeColor: AppColors.primary,
                  onChanged: _toggleEqualizer,
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Text(
              'FREQUENCY BANDS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            Text(
              '${equalizer.bands.length} BANDS',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...equalizer.bands.map((band) {
          final current = _draftLevels[band.index] ??
              band.levelMillibels.toDouble();
          final safeValue = current.clamp(minLevel, maxLevel).toDouble();
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatFrequency(band.centerFrequencyHz),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${(safeValue / 100).toStringAsFixed(1)} dB',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Slider(
                  min: minLevel,
                  max: maxLevel > minLevel ? maxLevel : minLevel + 1,
                  value: safeValue,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: equalizer.enabled
                      ? (value) {
                          setState(() => _draftLevels[band.index] = value);
                        }
                      : null,
                  onChangeEnd: equalizer.enabled
                      ? (value) => _applyBandLevel(band.index, value)
                      : null,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: equalizer.enabled
                ? () {
                    for (final band in equalizer.bands) {
                      _draftLevels[band.index] = 0;
                    }
                    setState(() {});
                    for (final band in equalizer.bands) {
                      _applyBandLevel(band.index, 0);
                    }
                  }
                : null,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Reset flat'),
          ),
        ),
        if (_message != null) ...[
          const SizedBox(height: 12),
          Text(
            _message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Band dan rentang level mengikuti kemampuan perangkat.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatFrequency(int frequencyHz) {
    if (frequencyHz >= 1000) {
      final khz = frequencyHz / 1000;
      return '${khz.toStringAsFixed(khz == khz.roundToDouble() ? 0 : 1)} kHz';
    }
    return '$frequencyHz Hz';
  }
}

class _UnavailableState extends StatelessWidget {
  const _UnavailableState({
    required this.message,
    required this.onRefresh,
    required this.isRefreshing,
  });

  final String message;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.graphic_eq_rounded,
              size: 42,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Equalizer unavailable',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: isRefreshing ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
