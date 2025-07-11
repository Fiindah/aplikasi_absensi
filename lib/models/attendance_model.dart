// lib/models/attendance_model.dart

class AttendanceResponse {
  final String message;
  final AttendanceData? data;
  final Map<String, dynamic>? errors; // Untuk menangani error validasi dari API

  AttendanceResponse({required this.message, this.data, this.errors});

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      message: json['message'] ?? 'Terjadi kesalahan tidak dikenal',
      data: json['data'] != null ? AttendanceData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data?.toJson(), 'errors': errors};
  }
}

class AttendanceData {
  final int id;
  final String attendanceDate;
  final String? checkInTime;
  final double? checkInLat;
  final double? checkInLng;
  final String? checkInLocation;
  final String? checkInAddress;
  final String status; // 'masuk', 'pulang', 'izin', 'belum_absen'
  final String? alasanIzin;
  final String? checkOutTime; // Nullable for check-in response
  final double? checkOutLat; // Nullable for check-in response
  final double? checkOutLng; // Nullable for check-in response
  final String? checkOutLocation; // Nullable for check-in response
  final String? checkOutAddress; // Nullable for check-in response

  AttendanceData({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    required this.status,
    this.alasanIzin,
    this.checkOutTime,
    this.checkOutLat,
    this.checkOutLng,
    this.checkOutLocation,
    this.checkOutAddress,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: json['id'],
      attendanceDate: json['attendance_date'],
      checkInTime: json['check_in_time'],
      checkInLat: (json['check_in_lat'] as num?)?.toDouble(),
      checkInLng: (json['check_in_lng'] as num?)?.toDouble(),
      checkInLocation: json['check_in_location'],
      checkInAddress: json['check_in_address'],
      status: json['status'],
      alasanIzin: json['alasan_izin'],
      checkOutTime: json['check_out_time'],
      checkOutLat: (json['check_out_lat'] as num?)?.toDouble(),
      checkOutLng: (json['check_out_lng'] as num?)?.toDouble(),
      checkOutLocation: json['check_out_location'],
      checkOutAddress: json['check_out_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendance_date': attendanceDate,
      'check_in_time': checkInTime,
      'check_in_lat': checkInLat,
      'check_in_lng': checkInLng,
      'check_in_location': checkInLocation,
      'check_in_address': checkInAddress,
      'status': status,
      'alasan_izin': alasanIzin,
      'check_out_time': checkOutTime,
      'check_out_lat': checkOutLat,
      'check_out_lng': checkOutLng,
      'check_out_location': checkOutLocation,
      'check_out_address': checkOutAddress,
    };
  }
}
