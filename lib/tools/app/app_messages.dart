import 'package:flutter/material.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/route_tools.dart';

class AppMessages {
  AppMessages._();

  static const _noText = 'NaT';

  static BuildContext _getContext(){
    return RouteTools.getTopContext()!;
  }
  
  static String httpMessage(String? cause) {
    if(cause == null){
      return errorOccur;
    }

    return _getContext().tInMap('httpCodes', cause)?? errorOccur;
  }

  static String operationMessage(String key) {
    return _getContext().tInMap('operationSection', key)?? _noText;
  }

  static String loginMessage(String key) {
    return _getContext().tInMap('loginSection', key)?? _noText;
  }

  static String trans(String key) {
    return _getContext().t(key)?? _noText;
  }

  static String transCap(String key) {
    return _getContext().tC(key)?? _noText;
  }

  static String get ok {
    return _getContext().tC('ok')?? _noText;
  }

  static String get yes {
    return _getContext().tC('yes')?? _noText;
  }

  static String get no {
    return _getContext().tC('no')?? _noText;
  }

  static String get select {
    return _getContext().t('select')?? _noText;
  }

  static String get name {
    return _getContext().t('name')?? _noText;
  }

  static String get family {
    return _getContext().t('family')?? _noText;
  }

  static String get age {
    return _getContext().t('age')?? _noText;
  }

  static String get gender {
    return _getContext().t('gender')?? _noText;
  }

  static String get man {
    return _getContext().t('man')?? _noText;
  }

  static String get woman {
    return _getContext().t('woman')?? _noText;
  }

  static String get notice {
    return _getContext().t('notice')?? _noText;
  }

  static String get send {
    return _getContext().t('send')?? _noText;
  }

  static String get next {
    return _getContext().t('next')?? _noText;
  }

  static String get home {
    return _getContext().t('home')?? _noText;
  }

  static String get start {
    return _getContext().t('start')?? _noText;
  }

  static String get contactUs {
    return _getContext().t('contactUs')?? _noText;
  }

  static String get aboutUs {
    return _getContext().t('aboutUs')?? _noText;
  }

  static String get userName {
    return _getContext().t('userName')?? _noText;
  }

  static String get password {
    return _getContext().t('password')?? _noText;
  }

  static String get repeatPassword {
    final l1 = _getContext().tInMap('loginSection', 'repeatPassword');
    return l1?? _noText;
  }

  static String get pay {
    return _getContext().t('pay')?? _noText;
  }
  
  static String get register {
    return _getContext().t('register')?? _noText;
  }

  static String get signIn {
    return _getContext().t('signIp')?? _noText;
  }

  static String get signUp {
    return _getContext().t('signUp')?? _noText;
  }

  static String get logout {
    return _getContext().t('logout')?? _noText;
  }

  static String get exit {
    return _getContext().t('exit')?? _noText;
  }

  static String get back {
    return _getContext().t('back')?? _noText;
  }

  static String get search {
    return _getContext().t('search')?? _noText;
  }

  static String get later {
    return _getContext().t('later')?? _noText;
  }

  static String get update {
    return _getContext().t('update')?? _noText;
  }

  static String get save {
    return _getContext().t('save')?? _noText;
  }

  static String get downloadNewVersion {
    return _getContext().t('downloadNewVersion')?? _noText;
  }

  static String get directDownload {
    return _getContext().t('directDownload')?? _noText;
  }

  static String get validation {
    return loginMessage('validation');
  }

  static String get resendOtpCode {
    return loginMessage('resendOtpCode');
  }

  static String get otpCodeIsResend {
    return loginMessage('otpCodeIsResend');
  }

  static String get otpCodeIsInvalid {
    return loginMessage('otpCodeIsInvalid');
  }

  static String get doYouWantLogoutYourAccount {
    return loginMessage('doYouWantLogoutYourAccount');
  }

  static String get loginWithGoogle {
    return loginMessage('loginWithGoogle');
  }

  static String get forgotPassword {
    return loginMessage('forgotPassword');
  }

  static String get passwordRecovery {
    return loginMessage('passwordRecovery');
  }

  static String get countrySelection {
    return _getContext().tInMap('countrySection', 'countrySelection')?? _noText;
  }

  static String get newAppVersionIsOk {
    return _getContext().t('newAppVersionIsOk')?? _noText;
  }

  static String get pleaseWait {
    return _getContext().t('pleaseWait')?? _noText;
  }

  static String get termPolice {
    return _getContext().t('termPolice')?? _noText;
  }

  static String get mobileNumber {
    return _getContext().t('mobileNumber')?? _noText;
  }

  static String get loginBtn {
    return _getContext().t('login')?? _noText;
  }

  static String get nameMustBigger2Char {
    return loginMessage('nameMustBigger2Char');
  }

  static String get familyMustBigger2Char {
    return loginMessage('familyMustBigger2Char');
  }

  static String get emailIsNotCorrect {
    return loginMessage('emailIsNotCorrect');
  }

  static String get otherNumber {
    return loginMessage('otherNumber');
  }

  static String get enterVerifyCodeDesc {
    return loginMessage('validationDescription');
  }

 static String get pleaseEnterAPassword {
    return loginMessage('selectPassword');
  }

  static String get passwordsNotSame {
    return loginMessage('passwordsNotSame');
  }

  static String get passwordMust4Char {
    return loginMessage('passwordMust4Char');
  }

  static String get emailVerifyIsSentClickOn {
    return _getContext().t('emailVerifyIsSentClickOn')?? _noText;
  }

  static String get errorOccur {
    return _getContext().t('errorOccur')?? _noText;
  }

  static String get errorOccurTryAgain {
    return _getContext().t('errorOccurTryAgain')?? _noText;
  }

  static String get wantToLeave {
    return _getContext().t('wantToLeave')?? _noText;
  }

  static String get e404 {
    return _getContext().t('thisPageNotFound')?? _noText;
  }

  static String get tryAgain {
    return _getContext().t('tryAgain')?? _noText;
  }

  static String get cancel {
    return _getContext().t('cancel')?? _noText;
  }

  static String get tokenIsIncorrectOrExpire {
    return httpMessage('tokenIsIncorrectOrExpire');
  }

  static String get databaseError {
    return httpMessage('databaseError');
  }

  static String get userNameOrPasswordIncorrect {
    return httpMessage('userNameOrPasswordIncorrect');
  }

  static String get errorOccurredInSubmittedParameters {
    return httpMessage('errorOccurredInSubmittedParameters');
  }

  static String get dataNotFound {
    return httpMessage('dataNotFound');
  }

  static String get thisRequestNotDefined {
    return httpMessage('thisRequestNotDefined');
  }

  static String get informationWasSend {
    return httpMessage('informationWasSend');
  }

  static String get errorUploadingData {
    return httpMessage('errorUploadingData');
  }

  static String get netConnectionIsDisconnect {
    return httpMessage('netConnectionIsDisconnect');
  }

  static String get errorCommunicatingServer {
    return httpMessage('errorCommunicatingServer');
  }

  static String get serverNotRespondProperly {
    return httpMessage('serverNotRespondProperly');
  }

  static String get accountIsBlock {
    return httpMessage('accountIsBlock');
  }

  static String get accountNotFound {
    return loginMessage('accountNotFound');
  }

  static String get operationCannotBePerformed {
    return operationMessage('operationCannotBePerformed');
  }

  static String get operationSuccess {
    return operationMessage('successOperation');
  }

  static String get operationFailed {
    return operationMessage('operationFailed');
  }

  static String get operationFailedTryAgain {
    return operationMessage('operationFailedTryAgain');
  }

  static String get operationCanceled {
    return operationMessage('operationCanceled');
  }

  static String get sorryYouDoNotHaveAccess {
    return _getContext().t('sorryYouDoNotHaveAccess')?? _noText;
  }

  static String get youMustRegister {
    return _getContext().t('youMustRegister')?? _noText;
  }

  static String get thereAreNoResults {
    return _getContext().t('thereAreNoResults')?? _noText;
  }
  
  static String get requestDataIsNotJson {
    return 'request data is not a json';
  }
  
  static String get requestKeyNotExist {
    return "'request' key not exist";
  }

  static String get iRealized {
    return _getContext().t('IRealized')?? _noText;
  }

  static String get unKnow {
    return _getContext().t('unknown')?? _noText;
  }

  static String get open {
    return _getContext().t('open')?? _noText;
  }

  static String get close {
    return _getContext().t('close')?? _noText;
  }

  static String get email {
    return _getContext().t('email')?? _noText;
  }

  static String get inEmailSignOutError {
    return _getContext().t('inEmailSignOutError')?? _noText;
  }

  static String get verifyEmail {
    return _getContext().t('verifyEmail')?? _noText;
  }

  ///---------------------------------------------------------------------------
  static String get appName {
    return 'وسعت ذهن';
  }

  static String get profileTitle {
    return _getContext().tC('profile')?? _noText;
  }

  static String get pleaseEnterVerifyCode {
    return 'لطفا کد ارسال شده را وارد کنید';//todo
  }

  static String get selectASimCard {
    return 'لطفا یک سیم کارت انتخاب کنید';//todo
  }

  static String get bePatient {
    return 'صبور باشید';
  }

  static String get lastUpdate {
    return ' بروز رسانی';//آخرین
  }

  static String get deviceStatus {
    return 'وضعیت دستگاه';
  }

  static String get simCardStatus {
    return 'وضعیت سیم کارت';
  }

  static String get zoneState {
    return 'وضعیت مناطق (زون ها)';
  }

  static String get zoneStatus {
    return 'حالت مناطق (زون ها)';
  }

  static String get batteryStatus {
    return 'وضعیت باتری';
  }

  static String get powerStatus {
    return 'وضعیت برق';
  }

  static String get listening {
    return 'شنود محیط';
  }

  static String get connectedPower {
    return 'متصل به برق';
  }

  static String get unConnectedPower {
    return 'قطع برق';
  }

  static String get mustAddAPlaceDescription {
    return 'شما هنور هیچ دستگاهی ثبت نکرده اید.';
  }

  static String get nameIsShort {
    return 'نام کوتاه است';
  }

  static String get simCardNumberIsInvalid {
    return 'شماره سیم کارت درست نیست';
  }

  static String get adminNumberIsInvalid {
    return 'شماره همراه مدیر درست نیست';
  }

  static String get needToUpdate {
    return 'بدون بروز رسانی';
  }

  static String get edit {
    return 'ویرایش';
  }

  static String get manage {
    return 'مدیریت';
  }

  static String get openState {
    return 'باز';
  }

  static String get closeState {
    return 'بسته';
  }

  static String get remoteManageDescription {
    return 'اگر ریموت ی گم شود،  می توانید از اینجا آن را مطابق شماره ی آن حذف کنید.';
  }

}
