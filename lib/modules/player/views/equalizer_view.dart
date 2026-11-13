import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../models/audio_effects_capabilities.dart';
import '../models/audio_equalizer_preset.dart';
import '../services/dn_audio_handler.dart';
import '../controllers/equalizer_controller.dart';

class EqualizerView extends StatefulWidget {
  const EqualizerView({
    super.key,
    this.isBottomSheet = true,
    this.compact = false,
  });

  final bool isBottomSheet;
  final bool compact;

  @override
  State<EqualizerView> createState() => _EqualizerViewState();
}

class _EqualizerViewState extends State<EqualizerView> {
  late final DnAudioHandler _handler;
  late final EqualizerController _equalizerController;
  final Map<int, double> _draftLevels = {};
  bool _isRefreshing = false;
  bool _isToggling = false;
  String? _message;
  String? _selectedPresetId = 'flat';
  bool _isApplyingPreset = false;
  bool _isUpdatingOptionalEffect = false;
  final Map<String, double> _optionalDraftStrength = {};

  @override
  void initState() {
    super.initState();
    _handler = Get.find<DnAudioHandler>();
    _equalizerController = Get.find<EqualizerController>();
    _selectedPresetId = _equalizerController.selectedPresetId.value;
    _refreshCapabilities();
  }

  Future<void> _refreshCapabilities() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _handler.audioEffectsService.getCapabilities();
    await _equalizerController.retryRestoreForCurrentSession();
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
    if (success) {
      await _equalizerController.persistCurrentSettings(
        presetId: _selectedPresetId ?? 'custom',
      );
    }
    if (!mounted) return;
    setState(() {
      _isToggling = false;
      if (!success) {
        _message = 'Pengaturan Equalizer gagal diterapkan.';
      }
    });
  }

  Future<void> _applyPreset(
    AudioEqualizerPreset preset,
    AudioEffectCapability equalizer,
  ) async {
    if (_isApplyingPreset || !equalizer.enabled) return;
    final minLevel = equalizer.minLevelMillibels;
    final maxLevel = equalizer.maxLevelMillibels;
    if (minLevel == null || maxLevel == null) return;

    final levels = preset.levelsForBands(
      equalizer.bands,
      minLevelMillibels: minLevel,
      maxLevelMillibels: maxLevel,
    );
    setState(() {
      _isApplyingPreset = true;
      _selectedPresetId = null;
      _draftLevels
        ..clear()
        ..addAll({for (final entry in levels.entries) entry.key: entry.value.toDouble()});
      _message = null;
    });

    var success = true;
    for (final entry in levels.entries) {
      final applied = await _handler.audioEffectsService.setBandLevel(
        entry.key,
        entry.value,
      );
      if (!applied) {
        success = false;
        break;
      }
    }

    if (success) {
      await _equalizerController.persistCurrentSettings(presetId: preset.id);
    }
    if (!mounted) return;
    setState(() {
      _isApplyingPreset = false;
      _draftLevels.clear();
      _selectedPresetId = success ? preset.id : null;
      _message = success
          ? null
          : 'Preset tidak dapat diterapkan sepenuhnya. Coba pilih ulang.';
    });
  }

  Future<void> _setOptionalEffect({
    required bool isBassBoost,
    required bool enabled,
    required int strength,
  }) async {
    if (_isUpdatingOptionalEffect) return;
    setState(() {
      _isUpdatingOptionalEffect = true;
      _message = null;
    });
    final success = isBassBoost
        ? await _handler.audioEffectsService.setBassBoost(
            enabled: enabled, strength: strength)
        : await _handler.audioEffectsService.setVirtualizer(
            enabled: enabled, strength: strength);
    if (success) {
      await _equalizerController.persistCurrentSettings(
        presetId: _selectedPresetId ?? 'custom',
      );
    }
    if (!mounted) return;
    setState(() {
      _isUpdatingOptionalEffect = false;
      if (!success) {
        _message = isBassBoost
            ? 'Bass enhancement gagal diterapkan.'
            : 'Virtualizer gagal diterapkan.';
      }
    });
  }

  Widget _buildOptionalEffectCard({
    required String title,
    required String description,
    required AudioEffectCapability capability,
    required bool isBassBoost,
  }) {
    if (!capability.supported) return const SizedBox.shrink();
    final minStrength = capability.minStrength ?? 0;
    final maxStrength = capability.maxStrength ?? 1000;
    final strength = (_optionalDraftStrength[isBassBoost ? 'bass' : 'virtual'] ??
            (capability.strength ?? minStrength).toDouble())
        .clamp(minStrength.toDouble(), maxStrength.toDouble())
        .toDouble();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: capability.enabled,
                activeThumbColor: AppColors.primary,
                onChanged: _isUpdatingOptionalEffect
                    ? null
                    : (enabled) => _setOptionalEffect(
                          isBassBoost: isBassBoost,
                          enabled: enabled,
                          strength: strength.round()),
              ),
            ],
          ),
          if (capability.strengthSupported == true &&
              maxStrength > minStrength) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('INTENSITY', style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
                const Spacer(),
                Text('${(strength / 10).round()}%', style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
              ],
            ),
            Slider(
              min: minStrength.toDouble(),
              max: maxStrength.toDouble(),
              value: strength,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.border,
              onChanged: capability.enabled && !_isUpdatingOptionalEffect
                  ? (value) => setState(() {
                        _optionalDraftStrength[isBassBoost ? 'bass' : 'virtual'] = value;
                      })
                  : null,
              onChangeEnd: capability.enabled && !_isUpdatingOptionalEffect
                  ? (value) => _setOptionalEffect(
                        isBassBoost: isBassBoost,
                        enabled: capability.enabled,
                        strength: value.round())
                  : null,
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'Perangkat hanya menyediakan kontrol ON/OFF untuk efek ini.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ],
      ),
    );
  }

  Future<void> _applyBandLevel(int index, double value) async {
    final success = await _handler.audioEffectsService.setBandLevel(
      index,
      value.round(),
    );
    if (success) {
      await _equalizerController.persistCurrentSettings(presetId: 'custom');
    }
    if (!mounted) return;
    setState(() {
      _draftLevels.remove(index);
      _selectedPresetId = null;
      _message = success ? null : 'Level band gagal diterapkan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = _handler.audioEffectsService;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: widget.compact
            ? MediaQuery.sizeOf(context).height * 0.52
            : widget.isBottomSheet
                ? MediaQuery.sizeOf(context).height * 0.84
                : double.infinity,
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
                      if (widget.isBottomSheet) ...[
                        Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 22),
                      ] else
                        const SizedBox(height: 8),
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
                  child: widget.compact
                      ? _buildQuickContent(context, capabilities, equalizer)
                      : _buildContent(capabilities, equalizer),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickContent(
    BuildContext context,
    AudioEffectsCapabilities capabilities,
    AudioEffectCapability equalizer,
  ) {
    if (!capabilities.available ||
        (!equalizer.supported &&
            !capabilities.bassBoost.supported &&
            !capabilities.virtualizer.supported)) {
      return _UnavailableState(
        message: capabilities.error ??
            equalizer.error ??
            'Equalizer belum tersedia pada sesi audio ini.',
        onRefresh: _refreshCapabilities,
        isRefreshing: _isRefreshing,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Equalizer', style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
                    SizedBox(height: 3),
                    Text('Master audio control', style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: equalizer.enabled,
                activeThumbColor: AppColors.primary,
                onChanged: equalizer.supported ? _toggleEqualizer : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'QUICK PRESETS',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AudioEqualizerPreset.presets.map((preset) {
            final selected =
                _equalizerController.selectedPresetId.value == preset.id;
            return ChoiceChip(
              label: Text(preset.name),
              selected: selected,
              onSelected: equalizer.enabled && !_isApplyingPreset
                  ? (value) {
                      if (value) _applyPreset(preset, equalizer);
                    }
                  : null,
              selectedColor: AppColors.primary.withValues(alpha: 0.22),
              backgroundColor: AppColors.surfaceElevated,
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              showCheckmark: false,
            );
          }).toList(growable: false),
        ),
        if (_isApplyingPreset) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(minHeight: 2),
        ],
        if (_message != null) ...[
          const SizedBox(height: 12),
          Text(
            _message!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            Future<void>.delayed(Duration.zero, () {
              Get.bottomSheet<void>(
                const EqualizerView(),
                isScrollControlled: true,
                backgroundColor: AppColors.surface,
              );
            });
          },
          icon: const Icon(Icons.tune_rounded),
          label: const Text('Open full equalizer'),
        ),
      ],
    );
  }

  Widget _buildContent(
    AudioEffectsCapabilities capabilities,
    AudioEffectCapability equalizer,
  ) {
    if (!capabilities.available ||
        (!equalizer.supported &&
            !capabilities.bassBoost.supported &&
            !capabilities.virtualizer.supported)) {
      return _UnavailableState(
        message: capabilities.error ??
            equalizer.error ??
            'Equalizer belum tersedia pada sesi audio ini.',
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
                  activeThumbColor: AppColors.primary,
                  onChanged: equalizer.supported ? _toggleEqualizer : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Text(
              'SOUND PRESETS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            if (_isApplyingPreset)
              const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AudioEqualizerPreset.presets.map((preset) {
            return ChoiceChip(
              label: Text(preset.name),
              selected: _equalizerController.selectedPresetId.value == preset.id,
              onSelected: equalizer.enabled && !_isApplyingPreset
                  ? (selected) {
                      if (selected) _applyPreset(preset, equalizer);
                    }
                  : null,
              selectedColor: AppColors.primary.withValues(alpha: 0.22),
              backgroundColor: AppColors.surfaceElevated,
              side: BorderSide(
                color: _equalizerController.selectedPresetId.value == preset.id
                    ? AppColors.primary
                    : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: _equalizerController.selectedPresetId.value == preset.id
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              showCheckmark: false,
            );
          }).toList(growable: false),
        ),
        const SizedBox(height: 8),
        Text(
          AudioEqualizerPreset.findById(_equalizerController.selectedPresetId.value)?.description ??
              'Pilih preset untuk menyesuaikan karakter suara.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
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
                  onChanged: equalizer.enabled && !_isApplyingPreset
                      ? (value) {
                          setState(() => _draftLevels[band.index] = value);
                        }
                      : null,
                  onChangeEnd: equalizer.enabled && !_isApplyingPreset
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
            onPressed: equalizer.enabled && !_isApplyingPreset
                ? () => _applyPreset(
                      AudioEqualizerPreset.findById('flat')!,
                      equalizer,
                    )
                : null,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Reset flat'),
          ),
        ),
        _buildOptionalEffectCard(
          title: 'Bass Enhancement',
          description: 'Perkuat frekuensi rendah',
          capability: capabilities.bassBoost,
          isBassBoost: true,
        ),
        _buildOptionalEffectCard(
          title: 'Virtualizer',
          description: 'Efek ruang dan keluasan suara',
          capability: capabilities.virtualizer,
          isBassBoost: false,
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
