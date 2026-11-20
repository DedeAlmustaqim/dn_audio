import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
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
        borderRadius: AppRadius.medium,
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
                activeThumbColor: AppColors.controlActive,
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
                Text('intensity'.tr, style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2)),
                const Spacer(),
                Text('${(strength / 10).round()}%', style: const TextStyle(
                  color: AppColors.controlActive,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
              ],
            ),
            Slider(
              min: minStrength.toDouble(),
              max: maxStrength.toDouble(),
              value: strength,
              activeColor: AppColors.controlActive,
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
            Text(
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
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.md, AppSpacing.md, AppSpacing.md),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'equalizer'.tr,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'sound_control'.tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'retry'.tr,
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.lg, AppSpacing.screenHorizontal, AppSpacing.xl),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.medium,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('equalizer'.tr, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
                    SizedBox(height: 3),
                    Text('master_audio_control'.tr, style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: equalizer.enabled,
                activeThumbColor: AppColors.controlActive,
                onChanged: equalizer.supported ? _toggleEqualizer : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'QUICK PRESETS',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
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
              selectedColor: AppColors.controlSelectedSurface,
              backgroundColor: AppColors.surfaceElevated,
              side: BorderSide(
                color: selected ? AppColors.controlActive : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: selected
                    ? AppColors.controlActive
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
            style: const TextStyle(color: AppColors.error, fontSize: 12),
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
          label: Text('open_full_equalizer'.tr),
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.lg, AppSpacing.screenHorizontal, AppSpacing.xxxl),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.medium,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'equalizer'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'enable_frequency_control'.tr,
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
                  activeThumbColor: AppColors.controlActive,
                  onChanged: equalizer.supported ? _toggleEqualizer : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Text(
              'sound_presets'.tr,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
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
              selectedColor: AppColors.controlSelectedSurface,
              backgroundColor: AppColors.surfaceElevated,
              side: BorderSide(
                color: _equalizerController.selectedPresetId.value == preset.id
                    ? AppColors.controlActive
                    : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: _equalizerController.selectedPresetId.value == preset.id
                    ? AppColors.controlActive
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
            Text(
              'frequency_bands'.tr,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            Text(
              '${equalizer.bands.length} BANDS',
              style: const TextStyle(
                color: AppColors.controlActive,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.medium,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(maxLevel / 100).toStringAsFixed(0)} dB',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    '0 dB',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    '${(minLevel / 100).toStringAsFixed(0)} dB',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: equalizer.bands.map((band) {
                    final current = _draftLevels[band.index] ??
                        band.levelMillibels.toDouble();
                    final safeValue = current.clamp(minLevel, maxLevel).toDouble();
                    final enabled = equalizer.enabled && !_isApplyingPreset;
                    return SizedBox(
                      width: 62,
                      child: Column(
                        children: [
                          Text(
                            (safeValue / 100).toStringAsFixed(1),
                            style: TextStyle(
                              color: enabled
                                  ? AppColors.controlActive
                                  : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _VerticalBandSlider(
                            value: safeValue,
                            min: minLevel,
                            max: maxLevel > minLevel ? maxLevel : minLevel + 1,
                            enabled: enabled,
                            onChanged: (value) {
                              setState(() => _draftLevels[band.index] = value);
                            },
                            onChangeEnd: (value) =>
                                _applyBandLevel(band.index, value),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatFrequency(band.centerFrequencyHz),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
            ],
          ),
        ),
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
            label: Text('reset_flat'.tr),
          ),
        ),
        _buildOptionalEffectCard(
          title: 'bass_enhancement'.tr,
          description: 'bass_description'.tr,
          capability: capabilities.bassBoost,
          isBassBoost: true,
        ),
        _buildOptionalEffectCard(
          title: 'virtualizer'.tr,
          description: 'virtualizer_description'.tr,
          capability: capabilities.virtualizer,
          isBassBoost: false,
        ),
        if (_message != null) ...[
          const SizedBox(height: 12),
          Text(
            _message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'device_band_note'.tr,
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


class _VerticalBandSlider extends StatefulWidget {
  const _VerticalBandSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double value;
  final double min;
  final double max;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  State<_VerticalBandSlider> createState() => _VerticalBandSliderState();
}

class _VerticalBandSliderState extends State<_VerticalBandSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant _VerticalBandSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  double _valueAt(double dy, double height) {
    final fraction = (1 - (dy / height)).clamp(0.0, 1.0);
    return widget.min + (widget.max - widget.min) * fraction;
  }

  void _updateValue(double nextValue) {
    _currentValue = nextValue.clamp(widget.min, widget.max).toDouble();
    widget.onChanged(_currentValue);
  }

  void _commit(double nextValue) {
    _updateValue(nextValue);
    widget.onChangeEnd(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final safeValue = _currentValue.clamp(widget.min, widget.max).toDouble();
    return Semantics(
      slider: true,
      enabled: widget.enabled,
      value: '${(safeValue / 100).toStringAsFixed(1)} dB',
      increasedValue: '${((safeValue + 100).clamp(widget.min, widget.max) / 100).toStringAsFixed(1)} dB',
      decreasedValue: '${((safeValue - 100).clamp(widget.min, widget.max) / 100).toStringAsFixed(1)} dB',
      onIncrease: widget.enabled
          ? () => _commit((safeValue + 100).clamp(widget.min, widget.max).toDouble())
          : null,
      onDecrease: widget.enabled
          ? () => _commit((safeValue - 100).clamp(widget.min, widget.max).toDouble())
          : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled
            ? (details) => _commit(_valueAt(details.localPosition.dy, 172))
            : null,
        onVerticalDragUpdate: widget.enabled
            ? (details) => _updateValue(
                  _valueAt(details.localPosition.dy, 172),
                )
            : null,
        onVerticalDragEnd: widget.enabled
            ? (_) => widget.onChangeEnd(_currentValue)
            : null,
        child: SizedBox(
          width: 40,
          height: 172,
          child: CustomPaint(
            painter: _VerticalBandSliderPainter(
              value: safeValue,
              min: widget.min,
              max: widget.max,
              activeColor: widget.enabled
                  ? AppColors.controlActive
                  : AppColors.textMuted,
              trackColor: AppColors.border,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerticalBandSliderPainter extends CustomPainter {
  const _VerticalBandSliderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.activeColor,
    required this.trackColor,
  });

  final double value;
  final double min;
  final double max;
  final Color activeColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const trackWidth = 6.0;
    const thumbRadius = 8.0;
    final centerX = size.width / 2;
    final top = thumbRadius;
    final bottom = size.height - thumbRadius;
    final trackHeight = bottom - top;
    final zeroFraction = (0 - min) / (max - min);
    final zeroY = bottom - (zeroFraction.clamp(0.0, 1.0) * trackHeight);
    final valueFraction = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final valueY = bottom - (valueFraction * trackHeight);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(centerX, top), Offset(centerX, bottom), trackPaint);

    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(centerX, zeroY), Offset(centerX, valueY), activePaint);

    final thumbPaint = Paint()..color = activeColor;
    canvas.drawCircle(Offset(centerX, valueY), thumbRadius, thumbPaint);
    canvas.drawCircle(
      Offset(centerX, valueY),
      3.0,
      Paint()..color = AppColors.background,
    );
    canvas.drawCircle(
      Offset(centerX, zeroY),
      2.2,
      Paint()..color = AppColors.textMuted.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant _VerticalBandSliderPainter oldDelegate) =>
      value != oldDelegate.value ||
      min != oldDelegate.min ||
      max != oldDelegate.max ||
      activeColor != oldDelegate.activeColor ||
      trackColor != oldDelegate.trackColor;
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
            Text(
              'equalizer_unavailable'.tr,
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
              label: Text('try_again'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
