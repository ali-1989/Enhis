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
    return _getContext().tC('select')?? _noText;
  }

  static String get name {
    return _getContext().tC('name')?? _noText;
  }

  static String get family {
    return _getContext().tC('family')?? _noText;
  }

  static String get age {
    return _getContext().tC('age')?? _noText;
  }

  static String get gender {
    return _getContext().tC('gender')?? _noText;
  }

  static String get man {
    return _getContext().tC('man')?? _noText;
  }

  static String get woman {
    return _getContext().tC('woman')?? _noText;
  }

  static String get notice {
    return _getContext().t('notice')?? _noText;
  }

  static String get send {
    return _getContext().t('send')?? _noText;
  }

  static String get home {
    return _getContext().t('home')?? _noText;
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

  static String get pay {
    return _getContext().t('pay')?? _noText;
  }

  static String get payWitIran {
    return _getContext().t('payWitIran')?? _noText;
  }

  static String get payWitPaypal {
    return _getContext().t('payWitPaypal')?? _noText;
  }

  static String get logout {
    return _getContext().t('logout')?? _noText;
  }

  static String get exit {
    return _getContext().t('exit')?? _noText;
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

  static String get register {
    return _getContext().t('register')?? _noText;
  }

  static String get save {
    return _getContext().t('save')?? _noText;
  }

  static String get next {
    return _getContext().t('next')?? _noText;
  }

  static String get downloadNewVersion {
    return _getContext().t('downloadNewVersion')?? _noText;
  }

  static String get directDownload {
    return _getContext().t('directDownload')?? _noText;
  }

  static String get validation {
    return _getContext().tInMap('loginSection', 'validation')?? _noText;
  }

  static String get resendOtpCode {
    return _getContext().tInMap('loginSection', 'resendOtpCode')?? _noText;
  }

  static String get otpCodeIsResend {
    return _getContext().tInMap('loginSection', 'otpCodeIsResend')?? _noText;
  }

  static String get otpCodeIsInvalid {
    return _getContext().tInMap('loginSection', 'otpCodeIsInvalid')?? _noText;
  }

  static String get pleaseWait {
    return _getContext().t('pleaseWait')?? _noText;
  }

  static String get countrySelection {
    return _getContext().tInMap('countrySection', 'countrySelection')?? _noText;
  }

  static String get doYouWantLogoutYourAccount {
    return _getContext().tInMap('loginSection', 'doYouWantLogoutYourAccount')?? _noText;
  }

  static String get newAppVersionIsOk {
    return _getContext().t('newAppVersionIsOk')?? _noText;
  }

  static String get terms {
    return 'سیاست حفظ حریم خصوصی';//todo
  }

  static String get mobileNumber {
    return _getContext().t('mobileNumber')?? _noText;
  }

  static String get loginBtn {
    return _getContext().t('login')?? _noText;
  }

  static String get loginWithGoogle {
    return 'ورود با گوگل';//todo
  }

  static String get changeNumber {
    return 'شماره ی دیگر';//todo
  }

  static String get enterVerifyCode {
    return 'کد ارسال شده به شماره ی # را وارد کنید';//todo
  }

  static String get pleaseEnterMobileToSendCode {
    return 'لطفا شماره موبایل خود را جهت ارسال کد وارد کنید';//todo
  }

  static String get errorOccur {
    return _getContext().t('errorOccur')?? _noText;
  }

  static String get errorOccurTryAgain {
    return _getContext().t('errorOccurTryAgain')?? _noText;
  }

  static String get wantToLeave {
    return _getContext().tC('wantToLeave')?? _noText;
  }

  static String get e404 {
    return _getContext().tC('thisPageNotFound')?? _noText;
  }

  static String get tryAgain {
    return _getContext().t('tryAgain')?? _noText;
  }

  static String get requestKeyNotExist {
    return "'request' key not exist";
  }

  static String get requestDataIsNotJson {
    return 'request data is not a json';
  }

  static String get tokenIsIncorrectOrExpire {
    return _getContext().tInMap('httpCodes', 'tokenIsIncorrectOrExpire')?? _noText;
  }

  static String get databaseError {
    return _getContext().tInMap('httpCodes', 'databaseError')?? _noText;
  }

  static String get userNameOrPasswordIncorrect {
    return _getContext().tInMap('httpCodes', 'userNameOrPasswordIncorrect')?? _noText;
  }

  static String get errorOccurredInSubmittedParameters {
    return _getContext().tInMap('httpCodes', 'errorOccurredInSubmittedParameters')?? _noText;
  }

  static String get dataNotFound {
    return _getContext().tInMap('httpCodes', 'dataNotFound')?? _noText;
  }

  static String get thisRequestNotDefined {
    return _getContext().tInMap('httpCodes', 'thisRequestNotDefined')?? _noText;
  }

  static String get informationWasSend {
    return _getContext().tInMap('httpCodes', 'informationWasSend')?? _noText;
  }

  static String get errorUploadingData {
    return _getContext().tInMap('httpCodes', 'errorUploadingData')?? _noText;
  }

  static String get netConnectionIsDisconnect {
    return _getContext().tInMap('httpCodes', 'netConnectionIsDisconnect')?? _noText;
  }

  static String get errorCommunicatingServer {
    return _getContext().tInMap('httpCodes', 'errorCommunicatingServer')?? _noText;
  }

  static String get serverNotRespondProperly {
    return _getContext().tInMap('httpCodes', 'serverNotRespondProperly')?? _noText;
  }

  static String get accountIsBlock {
    return _getContext().tInMap('httpCodes', 'accountIsBlock')?? _noText;
  }

  static String get operationCannotBePerformed {
    return _getContext().tInMap('operationSection', 'operationCannotBePerformed')?? _noText;
  }

  static String get operationSuccess {
    return _getContext().tInMap('operationSection', 'successOperation')?? _noText;
  }

  static String get operationFailed {
    return _getContext().tInMap('operationSection', 'operationFailed')?? _noText;
  }

  static String get operationFailedTryAgain {
    return _getContext().tInMap('operationSection','operationFailedTryAgain')?? _noText;
  }

  static String get operationCanceled {
    return _getContext().tInMap('operationSection', 'operationCanceled')?? _noText;
  }

  static String get sorryYouDoNotHaveAccess {
    return _getContext().tC('sorryYouDoNotHaveAccess')?? _noText;
  }

  static String get youMustRegister {
    return _getContext().tC('youMustRegister')?? _noText;
  }

  static String get thereAreNoResults {
    return _getContext().tC('thereAreNoResults')?? _noText;
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

  static String get unKnow {
    return 'نا مشخص';//todo
  }

  static String get bePatient {
    return 'صبور باشید';
  }

  //============================================================================

  static String get open {
    return 'باز';
  }

  static String get close {
    return 'بسته';
  }

  static String get lastUpdate {
    return 'آخرین بروز رسانی';
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

  static String get remoteManageDescription {
    return 'اگر ریموت ی گم شود،  می توانید از اینجا آن را مطابق شماره ی آن حذف کنید.';
  }

}