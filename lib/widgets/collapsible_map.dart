// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:smart_parking_app/models/parking_place.dart';

// class CollapsibleMap extends StatefulWidget {
//   final List<ParkingPlace> places;
//   final bool isExpanded;
//   final VoidCallback onToggleExpanded;
//   final Function(ParkingPlace) onPlaceSelected;

//   const CollapsibleMap({
//     Key? key,
//     required this.places,
//     required this.isExpanded,
//     required this.onToggleExpanded,
//     required this.onPlaceSelected,
//   }) : super(key: key);

//   @override
//   State<CollapsibleMap> createState() => _CollapsibleMapState();
// }

// class _CollapsibleMapState extends State<CollapsibleMap> {
//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};

//   @override
//   void didUpdateWidget(CollapsibleMap oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.places != widget.places) {
//       _updateMarkers();
//     }
//   }

//   void _updateMarkers() {
//     setState(() {
//       _markers = widget.places.map((place) {
//         return Marker(
//           markerId: MarkerId(place.id),
//           position: LatLng(place.latitude, place.longitude),
//           infoWindow: InfoWindow(
//             title: place.name,
//             snippet: '${place.availableSlots} slots available',
//             onTap: () => widget.onPlaceSelected(place),
//           ),
//         );
//       }).toSet();
//     });
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     _updateMarkers();

//     if (widget.places.isNotEmpty) {
//       _fitBounds();
//     }
//   }

//   void _fitBounds() {
//     if (widget.places.isEmpty || _mapController == null) return;

//     double minLat = widget.places.first.latitude;
//     double maxLat = widget.places.first.latitude;
//     double minLng = widget.places.first.longitude;
//     double maxLng = widget.places.first.longitude;

//     for (var place in widget.places) {
//       if (place.latitude < minLat) minLat = place.latitude;
//       if (place.latitude > maxLat) maxLat = place.latitude;
//       if (place.longitude < minLng) minLng = place.longitude;
//       if (place.longitude > maxLng) maxLng = place.longitude;
//     }

//     _mapController!.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           southwest: LatLng(minLat - 0.01, minLng - 0.01),
//           northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
//         ),
//         50,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       height: widget.isExpanded ? MediaQuery.of(context).size.height * 0.7 : 200,
//       child: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: const CameraPosition(
//               target: LatLng(0, 0), // Will be updated in _fitBounds
//               zoom: 15,
//             ),
//             markers: _markers,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             mapToolbarEnabled: false,
//             zoomControlsEnabled: false,
//           ),
//           Positioned(
//             right: 16,
//             bottom: 16,
//             child: Column(
//               children: [
//                 FloatingActionButton.small(
//                   heroTag: 'expand_map',
//                   onPressed: widget.onToggleExpanded,
//                   child: Icon(
//                     widget.isExpanded ? Icons.close_fullscreen : Icons.open_in_full,
//                   ),
//                 ),
//                 if (widget.isExpanded) ...[
//                   const SizedBox(height: 8),
//                   FloatingActionButton.small(
//                     heroTag: 'fit_bounds',
//                     onPressed: _fitBounds,
//                     child: const Icon(Icons.center_focus_strong),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }