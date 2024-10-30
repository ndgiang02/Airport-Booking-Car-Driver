import 'dart:io';
import '../utils/preferences/preferences.dart';

class API {
  static const baseUrl = "http://appbooking.xyz/api/";
  static const apiKey = "";

  static Map<String, String> authheader = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
  };

  static Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    HttpHeaders.acceptHeader: 'application/json',
    'Authorization': 'Bearer ${Preferences.getString(Preferences.token)}',
    'apikey': apiKey,
  };


  static const userSignUP = "${baseUrl}register-driver";
  static const userLogin = "${baseUrl}login";
  static const getUserByPhone = "${baseUrl}get-user-by-phone";
  static const checkUser = "${baseUrl}check-phone";


  static const sendResetPasswordOtp = "${baseUrl}send-otp";
  static const resetPasswordOtp = "${baseUrl}reset-password-otp";
  static const changePassword = "${baseUrl}change-password";


  static const fetchTrips = "${baseUrl}fetch-trips";
  static const fetchVehicle = "${baseUrl}vehicle-types";
  static const changeStatus = "${baseUrl}contact-us";

  static const deleteUser = "${baseUrl}delete-user-account";
  static const logOut = "${baseUrl}logout";

  static const updateStatus = "${baseUrl}driver/update-status";
  static const updateLocation = "${baseUrl}driver/update-location";
  static const acceptTrip = "${baseUrl}driver/accept-trip";
  static const startTrip = "${baseUrl}driver/start-trip";
  static const completeTrip = "${baseUrl}driver/complete-trip";
  static const rejectTrip = "${baseUrl}driver/reject-trip";
  static const wallet = "${baseUrl}driver/my-wallet";

  static const acceptClusterTrip = "${baseUrl}driver/accept-cluster-trip";
  static const startClusterTrip = "${baseUrl}driver/start-cluster-trip";
  static const completeClusterTrip = "${baseUrl}driver/complete-cluster-trip";
  static const rejectClusterTrip = "${baseUrl}driver/reject-cluster-trip'";

  static const getVehicle = "${baseUrl}vehicle/get-vehicle";
  static const getTrip = "${baseUrl}driver/get-trip";

  static const introduction = "${baseUrl}intro";
  static const terms = "${baseUrl}terms";


  static const updateName = "${baseUrl}user-name";
  static const contactUs = "${baseUrl}contact-us";
  static const updateToken = "${baseUrl}update-fcm";
  static const rentVehicle = "${baseUrl}vehicle-get";
  static const getFcmToken = "${baseUrl}fcm-token";
  static const deleteFavouriteRide = "${baseUrl}delete-favorite-ride";
  static const rejectRide = "${baseUrl}set-rejected-requete";

}

