import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_transitions.dart';
import '../core/widgets/soft_panel.dart';
import '../core/widgets/profile_avatar.dart';
import '../services/location_service.dart';
import '../services/emergency_dispatch_service.dart';
import '../state/vault_state.dart';
import 'document_detail_screen.dart';

class EmergencyCardScreen extends StatefulWidget {
  const EmergencyCardScreen({super.key, required this.vaultState});

  final VaultState vaultState;

  @override
  State<EmergencyCardScreen> createState() => _EmergencyCardScreenState();
}

class _EmergencyCardScreenState extends State<EmergencyCardScreen> {
  bool _isFetchingGps = false;
  VaultGpsLocation? _currentGps;
  String? _gpsStatusMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
  }

  void _loadInitialLocation() {
    final profile = widget.vaultState.userProfile;
    if (LocationService.lastKnownGpsLocation != null) {
      _currentGps = LocationService.lastKnownGpsLocation;
    } else if (profile.lastKnownLatitude != 0.0 || profile.lastKnownLongitude != 0.0) {
      _currentGps = VaultGpsLocation(
        latitude: profile.lastKnownLatitude,
        longitude: profile.lastKnownLongitude,
        timestamp: DateTime.tryParse(profile.lastLocationTimestamp) ?? DateTime.now(),
      );
    }
  }

  Future<void> _fetchLiveGpsLocation() async {
    setState(() {
      _isFetchingGps = true;
      _gpsStatusMessage = null;
    });

    try {
      final loc = await LocationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        _isFetchingGps = false;
        if (loc.isSuccess) {
          _currentGps = loc;
          widget.vaultState.updateLastKnownLocation(loc.latitude, loc.longitude);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.mint,
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'GPS Acquired: ${loc.coordinatesString}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          _gpsStatusMessage = loc.errorMessage ?? 'Could not fetch GPS coordinates';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.crimson,
              content: Text(
                _gpsStatusMessage ?? 'Location fetch failed',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingGps = false;
        _gpsStatusMessage = e.toString();
      });
    }
  }

  void _shareEmergencyPass() {
    final profile = widget.vaultState.userProfile;
    final lat = _currentGps?.latitude ?? profile.lastKnownLatitude;
    final lon = _currentGps?.longitude ?? profile.lastKnownLongitude;
    final mapsUrl = (lat != 0.0 || lon != 0.0)
        ? LocationService.getGoogleMapsUrl(lat, lon)
        : 'Not recorded';

    final text = '🚨 LifeVault Emergency ICE Medical Pass\n'
        'Patient Name: ${profile.hasName ? profile.name : "LifeVault User"}\n'
        'Blood Group: ${profile.bloodGroup.isNotEmpty ? profile.bloodGroup : "Unknown"}\n'
        'Allergies: ${profile.allergies.isNotEmpty ? profile.allergies : "None reported"}\n'
        'Medical Conditions: ${profile.medicalConditions.isNotEmpty ? profile.medicalConditions : "None reported"}\n'
        'ICE Emergency Contact: ${profile.emergencyContactName} (${profile.emergencyContactPhone})\n'
        'Last Known Location: $mapsUrl';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('✓ Emergency ICE Pass copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = widget.vaultState.userProfile;
    final medicalDocs = widget.vaultState.documents
        .where((d) =>
            d.category == 'Medical' ||
            d.category == 'Insurance' ||
            d.category == 'Identity')
        .toList();

    final activeLat = _currentGps?.latitude ?? profile.lastKnownLatitude;
    final activeLon = _currentGps?.longitude ?? profile.lastKnownLongitude;
    final hasValidCoordinates = activeLat != 0.0 || activeLon != 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: const Text('Emergency ICE Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share ICE Pass',
            onPressed: _shareEmergencyPass,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Urgent Crimson Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.crimson,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.crimson.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emergency_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IN CASE OF EMERGENCY (ICE)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Offline Accessible Critical Health & Emergency Dispatch Pass',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 📍 Live GPS Coordinates & Location Card
                SoftPanel(
                  color: isDark ? const Color(0xFF16202C) : const Color(0xFFEFF5FC),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.coral.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.coral,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Last Known GPS Location',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          FilledButton.tonalIcon(
                            onPressed: _isFetchingGps ? null : _fetchLiveGpsLocation,
                            icon: _isFetchingGps
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location_rounded, size: 16),
                            label: Text(
                              _isFetchingGps ? 'Locating...' : 'Fetch GPS',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (hasValidCoordinates) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2836) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.06),
                            ),
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
                                        const Text(
                                          'COORDINATES (LAT, LON)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.muted,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${activeLat.toStringAsFixed(6)}, ${activeLon.toStringAsFixed(6)}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? Colors.white : AppColors.ink,
                                            fontFeatures: const [FontFeature.tabularFigures()],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    onPressed: () => EmergencyDispatchService.openMapLocation(
                                      context,
                                      latitude: activeLat,
                                      longitude: activeLon,
                                    ),
                                    icon: const Icon(Icons.map_rounded, size: 18),
                                    tooltip: 'Open in Google Maps',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'https://maps.google.com/?q=${activeLat.toStringAsFixed(6)},${activeLon.toStringAsFixed(6)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.coral,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2836) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppColors.muted, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _gpsStatusMessage ??
                                      'No GPS coordinates recorded yet. Tap "Fetch GPS" to capture live location.',
                                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Patient / Identity Card
                SoftPanel(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ProfileAvatar(
                            profile: profile,
                            size: 64,
                            borderRadius: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.hasName ? profile.name : 'LifeVault Owner',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.darkText : AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.email.isNotEmpty
                                      ? profile.email
                                      : 'Verified Vault Identity',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Blood Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.crimson.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.crimson.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'BLOOD',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.crimson,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  profile.bloodGroup.isNotEmpty ? profile.bloodGroup : 'N/A',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.crimson,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 28),

                      // Medical Details Grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Known Allergies',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.coral,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.allergies.isNotEmpty
                                      ? profile.allergies
                                      : 'None recorded',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkText : AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Medical Conditions',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.mint,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.medicalConditions.isNotEmpty
                                      ? profile.medicalConditions
                                      : 'None recorded',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkText : AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🚨 Primary Emergency Contact Card with Real Calling & GPS SMS
                SoftPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Primary Emergency Contact (ICE)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mint.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              profile.iceRelationship.isNotEmpty
                                  ? profile.iceRelationship
                                  : 'Primary',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.mint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.coral.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.contact_phone_rounded,
                            color: AppColors.coral,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          profile.emergencyContactName.isNotEmpty
                              ? profile.emergencyContactName
                              : 'Emergency Contact Not Set',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(
                          profile.emergencyContactPhone.isNotEmpty
                              ? profile.emergencyContactPhone
                              : 'Tap to configure in Settings',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Direct Mobile Call Button
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.mint.withValues(alpha: 0.18),
                                foregroundColor: AppColors.mint,
                              ),
                              onPressed: () {
                                EmergencyDispatchService.callEmergencyContact(
                                  context,
                                  phoneNumber: profile.emergencyContactPhone,
                                  contactName: profile.emergencyContactName,
                                );
                              },
                              icon: const Icon(Icons.phone_rounded, size: 20),
                              tooltip: 'Call Emergency Contact Directly',
                            ),
                            const SizedBox(width: 8),
                            // Direct GPS Location SMS Button
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.coral.withValues(alpha: 0.18),
                                foregroundColor: AppColors.coral,
                              ),
                              onPressed: () {
                                EmergencyDispatchService.sendEmergencySms(
                                  context,
                                  phoneNumber: profile.emergencyContactPhone,
                                  contactName: profile.emergencyContactName,
                                  latitude: _currentGps?.latitude ?? profile.lastKnownLatitude,
                                  longitude: _currentGps?.longitude ?? profile.lastKnownLongitude,
                                  bloodGroup: profile.bloodGroup,
                                  allergies: profile.allergies,
                                  userName: profile.name,
                                );
                              },
                              icon: const Icon(Icons.sms_rounded, size: 20),
                              tooltip: 'Send GPS Location SMS to Contact',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Secondary Emergency Contact (if set)
                if (profile.secondaryEmergencyContactPhone.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SoftPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Secondary Emergency Contact',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.butter.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                profile.secondaryIceRelationship.isNotEmpty
                                    ? profile.secondaryIceRelationship
                                    : 'Secondary',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.butter.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.amber,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            profile.secondaryEmergencyContactName.isNotEmpty
                                ? profile.secondaryEmergencyContactName
                                : 'Secondary Contact',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(profile.secondaryEmergencyContactPhone),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.filledTonal(
                                onPressed: () {
                                  EmergencyDispatchService.callEmergencyContact(
                                    context,
                                    phoneNumber: profile.secondaryEmergencyContactPhone,
                                    contactName: profile.secondaryEmergencyContactName,
                                  );
                                },
                                icon: const Icon(Icons.phone_rounded, size: 18),
                                tooltip: 'Call Secondary Contact',
                              ),
                              const SizedBox(width: 6),
                              IconButton.filledTonal(
                                onPressed: () {
                                  EmergencyDispatchService.sendEmergencySms(
                                    context,
                                    phoneNumber: profile.secondaryEmergencyContactPhone,
                                    contactName: profile.secondaryEmergencyContactName,
                                    latitude: _currentGps?.latitude ?? profile.lastKnownLatitude,
                                    longitude: _currentGps?.longitude ?? profile.lastKnownLongitude,
                                    bloodGroup: profile.bloodGroup,
                                    allergies: profile.allergies,
                                    userName: profile.name,
                                  );
                                },
                                icon: const Icon(Icons.sms_rounded, size: 18),
                                tooltip: 'Send GPS SMS to Secondary Contact',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Critical Stored Medical & Insurance Vault Records
                SoftPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attached Health & Insurance Records',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (medicalDocs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No medical, insurance, or identity documents stored in your vault yet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkMuted : AppColors.muted,
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: medicalDocs.length,
                          separatorBuilder: (_, _) => const Divider(height: 12),
                          itemBuilder: (context, index) {
                            final doc = medicalDocs[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                AppColors.getCategoryIcon(doc.category),
                                color: AppColors.getCategoryColor(doc.category),
                              ),
                              title: Text(
                                doc.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                '${doc.category}${doc.documentNumber != null ? ' • #${doc.documentNumber}' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  VaultFadeSlideRoute(
                                    builder: (_) => DocumentDetailScreen(
                                      document: doc,
                                      vaultState: widget.vaultState,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
