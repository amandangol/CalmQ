// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../../core/services/config_service.dart';

// class IPFSService {
//   final String _pinataApiKey;
//   final String _pinataSecretKey;
//   final String _pinataGateway;

//   IPFSService({
//     required String pinataApiKey,
//     required String pinataSecretKey,
//     required String pinataGateway,
//   }) : _pinataApiKey = pinataApiKey,
//        _pinataSecretKey = pinataSecretKey,
//        _pinataGateway = pinataGateway;

//   Future<String> uploadMetadata(Map<String, dynamic> metadata) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://api.pinata.cloud/pinning/pinJSONToIPFS'),
//         headers: {
//           'Content-Type': 'application/json',
//           'pinata_api_key': _pinataApiKey,
//           'pinata_secret_api_key': _pinataSecretKey,
//         },
//         body: jsonEncode(metadata),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final ipfsHash = data['IpfsHash'];
//         return 'ipfs://$ipfsHash';
//       } else {
//         throw Exception('Failed to upload metadata: ${response.body}');
//       }
//     } catch (e) {
//       print('Error uploading to IPFS: $e');
//       rethrow;
//     }
//   }

//   Future<String> uploadImage(List<int> imageBytes, String fileName) async {
//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://api.pinata.cloud/pinning/pinFileToIPFS'),
//       );

//       request.headers.addAll({
//         'pinata_api_key': _pinataApiKey,
//         'pinata_secret_api_key': _pinataSecretKey,
//       });

//       request.files.add(
//         http.MultipartFile.fromBytes('file', imageBytes, filename: fileName),
//       );

//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         final data = jsonDecode(responseBody);
//         final ipfsHash = data['IpfsHash'];
//         return 'ipfs://$ipfsHash';
//       } else {
//         throw Exception('Failed to upload image: $responseBody');
//       }
//     } catch (e) {
//       print('Error uploading image to IPFS: $e');
//       rethrow;
//     }
//   }

//   Future<String> uploadFile(List<int> fileBytes) async {
//     final url = Uri.parse('https://api.pinata.cloud/pinning/pinFileToIPFS');
//     final request = http.MultipartRequest('POST', url)
//       ..headers.addAll({
//         'pinata_api_key': _pinataApiKey,
//         'pinata_secret_api_key': _pinataSecretKey,
//       })
//       ..files.add(
//         http.MultipartFile.fromBytes('file', fileBytes, filename: 'badge.png'),
//       );

//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();
//     final json = jsonDecode(responseBody);

//     if (response.statusCode != 200) {
//       throw Exception('Failed to upload file to IPFS: ${json['error']}');
//     }

//     return json['IpfsHash'];
//   }

//   Future<String> uploadJson(Map<String, dynamic> json) async {
//     final url = Uri.parse('https://api.pinata.cloud/pinning/pinJSONToIPFS');
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'pinata_api_key': _pinataApiKey,
//         'pinata_secret_api_key': _pinataSecretKey,
//       },
//       body: jsonEncode({
//         'pinataMetadata': {'name': 'Badge Metadata'},
//         'pinataContent': json,
//       }),
//     );

//     final responseBody = jsonDecode(response.body);

//     if (response.statusCode != 200) {
//       throw Exception(
//         'Failed to upload JSON to IPFS: ${responseBody['error']}',
//       );
//     }

//     return responseBody['IpfsHash'];
//   }

//   String getGatewayUrl(String ipfsHash) {
//     return '$_pinataGateway/ipfs/$ipfsHash';
//   }
// }
