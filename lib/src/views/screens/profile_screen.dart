import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:validators/validators.dart';

import '../../../app_colors.dart';
import '../../controllers/user_controller.dart';
import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../repositories/setting_repository.dart';
import '../../repositories/user_repository.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/delete_account_confirmation_dialog.dart';
import '../widgets/menu.dart';
import '../widgets/profile_image_edit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends StateMVC<ProfileScreen> {
  late UserController _userCon;
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController =
      TextEditingController(text: currentUser.value.email);

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String phone = currentUser.value.phone;
  String name = currentUser.value.name;
  String email = currentUser.value.email;
  String password = "";

  String phoneError = "";
  String nameError = "";
  String emailError = "";
  String passwordError = "";

  ProfileScreenState() : super(UserController()) {
    _userCon = controller as UserController;
  }

  void clearError() {
    setState(() {
      phoneError = "";
      nameError = "";
      emailError = "";
      passwordError = "";
    });
  }

  @override
  void initState() {
    super.initState();
    AdaptiveTheme.getThemeMode().then((theme) =>
        setState(() => setting.value.theme = theme ?? AdaptiveThemeMode.light));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(

          backgroundColor: AppColors.mainBlue,
          title: Text(
            'Profile',
            style: khulaSemiBold.copyWith(
                color: Colors.white,
                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
          ),
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          elevation: 1,
          shadowColor: Theme.of(context).primaryColor,
        ),
        drawer: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Drawer(
            child: MenuWidget(),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    children: [
                      SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                      ProfileImageEdit(),
                      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        child: CustomTextFormField(
                          errorText: nameError,
                          initialValue: name,
                          isRequired: true,
                          validator: (String value) {
                            if (value.isEmpty || value.length <= 3) {
                              return AppLocalizations.of(context)!
                                  .enterFullName;
                            }
                            return null;
                          },
                          onSave: (String value) {
                            setState(() => name = value);
                          },
                          hintText: AppLocalizations.of(context)!.fullName,
                          labelText: AppLocalizations.of(context)!.fullName,
                          focusNode: _fullNameFocus,
                          nextFocus: _emailFocus,
                          inputType: TextInputType.name,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(150)
                          ],
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        child: CustomTextFormField(
                          controller: emailController,
                          errorText: emailError,
                          isRequired: true,
                          onSave: (String value) {
                            setState(() => email = value);
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(191)
                          ],
                          validator: (String value) {
                            if (value.isEmpty) {
                              return AppLocalizations.of(context)!.enterEmail;
                            } else if (!isEmail(value)) {
                              return AppLocalizations.of(context)!
                                  .enterValidEmail;
                            }
                            return null;
                          },
                          hintText: AppLocalizations.of(context)!.email,
                          labelText: AppLocalizations.of(context)!.email,
                          focusNode: _emailFocus,
                          nextFocus: _phoneFocus,
                          inputType: TextInputType.emailAddress,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        child: CustomTextFormField(
                          errorText: phoneError,
                          initialValue: phone,
                          isRequired: true,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .enterPhoneCorrectly;
                            } else if (value.length < 9) {
                              return AppLocalizations.of(context)!
                                  .enterPhoneCorrectly;
                            }
                            return null;
                          },
                          onSave: (String value) {
                            setState(() => phone = value);
                          },
                          hintText: AppLocalizations.of(context)!.phone,
                          labelText: AppLocalizations.of(context)!.phone,
                          focusNode: _phoneFocus,
                          nextFocus: _passwordFocus,
                          inputType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        child: CustomTextFormField(
                          errorText: passwordError,
                          controller: passwordController,
                          isRequired: true,
                          validator: (String value) {
                            if (value.isNotEmpty && value.length < 6) {
                              return AppLocalizations.of(context)!
                                  .inputMinimumSize(
                                      AppLocalizations.of(context)!.thePassword,
                                      6);
                            }
                            return null;
                          },
                          onSave: (String value) {
                            setState(() => password = value);
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(80)
                          ],
                          hintText: AppLocalizations.of(context)!.password,
                          labelText: AppLocalizations.of(context)!.password,
                          isPassword: true,
                          focusNode: _passwordFocus,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          margin: const EdgeInsets.only(
                              left: Dimensions.PADDING_SIZE_SMALL,
                              right: Dimensions.PADDING_SIZE_SMALL),
                          child: Container(
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: const Offset(0, 1)),
                              ],
                              color: AppColors.mainBlue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                              ),
                              onPressed: loading
                                  ? () {}
                                  : () async {
                                      clearError();
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        setState(() => loading = true);
                                        await _userCon
                                            .doProfileUpdate(name, email, phone,
                                                password: password)
                                            .then((value) {
                                          Fluttertoast.showToast(
                                              msg: AppLocalizations.of(context)!
                                                  .dataUpdatedSuccessfully);
                                        }).catchError((error) {
                                          setState(() => loading = false);
                                          if (error.message is Map) {
                                            error.message
                                                .forEach((index, value) {
                                              switch (index) {
                                                case "name":
                                                  setState(() =>
                                                      nameError = value[0]);
                                                  break;
                                                case "email":
                                                  setState(() =>
                                                      emailError = value[0]);
                                                  break;
                                                case "phone":
                                                  setState(() =>
                                                      phoneError = value[0]);
                                                  break;
                                                case "password":
                                                  setState(() =>
                                                      passwordError = value[0]);
                                                  break;
                                                default:
                                                  break;
                                              }
                                            });
                                          }
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .failedUpdate),
                                            backgroundColor:
                                                Theme.of(context).errorColor,
                                          ));
                                        });
                                        setState(() => loading = false);
                                        return;
                                      }
                                    },
                              child: loading
                                  ? CircularProgressIndicator(
                                      color: Theme.of(context).highlightColor)
                                  : Text(
                                      AppLocalizations.of(context)!.save,
                                      style: poppinsSemiBold.copyWith(
                                          color:
                                              Theme.of(context).highlightColor),
                                    ),
                            ),
                          )),
                    ],
                  ),
                ),
                ListTile(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) => DeleteAccountConfirmationDialog(
                        onConfirmed: () async {
                          await Future.delayed(Duration(seconds: 2));
                          await _userCon.doDeleteAccount().then((value) async {
                            await _userCon.doLogout();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/Login', (route) => false);
                            setState(() {});
                          });
                        },
                      ),
                    );
                  },
                  dense: true,
                  title: Text(
                    AppLocalizations.of(context)!.deleteMyAccount,
                    textAlign: TextAlign.center,
                    style: khulaSemiBold.copyWith(
                      color: AppColors.mainBlue,
                    ),
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