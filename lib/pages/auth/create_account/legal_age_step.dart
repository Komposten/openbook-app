import 'package:Openbook/pages/auth/create_account/blocs/create_account.dart';
import 'package:Openbook/provider.dart';
import 'package:Openbook/services/localization.dart';
import 'package:Openbook/services/validation.dart';
import 'package:Openbook/widgets/buttons/button.dart';
import 'package:Openbook/widgets/buttons/secondary_button.dart';
import 'package:Openbook/widgets/buttons/success_button.dart';
import 'package:Openbook/widgets/fields/checkbox_field.dart';
import 'package:Openbook/widgets/fields/text_form_field.dart';
import 'package:flutter/material.dart';


class OBAuthLegalAgeStepPage extends StatefulWidget {
   @override
  State<StatefulWidget> createState() {
    return OBAuthLegalAgeStepPageState();
  }
}

class OBAuthLegalAgeStepPageState extends State<OBAuthLegalAgeStepPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool isAgeConfirmed;
  CreateAccountBloc createAccountBloc;
  LocalizationService localizationService;

  @override
  void initState() {
    isAgeConfirmed = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    localizationService = openbookProvider.localizationService;
    createAccountBloc = openbookProvider.createAccountBloc;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    _buildConfirmLegalAgeText(),
                    SizedBox(
                      height: 20.0,
                    ),
                    _buildLegalAgeForm(),
                  ],
                ))),
      ),
      backgroundColor: Color(0xFFFF4A6B),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: _buildPreviousButton(context: context),
              ),
              Expanded(child: _buildNextButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmLegalAgeText() {
    String almostThereText = localizationService.trans('AUTH.CREATE_ACC.ALMOST_THERE');

    return Column(
      children: <Widget>[
        SizedBox(
          width: 10.0
        ),
        Text(
          '🏁',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        Text(
          almostThereText,
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLegalAgeForm() {
    return Form(
      key: _formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            OBCheckboxField(
              value: isAgeConfirmed,
              title: '',
              onTap: () {
                setState(() {
                  createAccountBloc.setLegalAgeConfirmation(isAgeConfirmed);
                  isAgeConfirmed = !isAgeConfirmed;
                });
              },
              leading: Container(
                child: Text('Are you older than 16 years', style: TextStyle(fontSize: 16.0, color: Colors.white)),
              ),
            )
          ]),
    );
  }

  Widget _buildNextButton() {
    String buttonText = localizationService.trans('AUTH.CREATE_ACC.NEXT');

    return OBSuccessButton(
            minWidth: double.infinity,
            size: OBButtonSize.large,
            child: Text(buttonText, style: TextStyle(fontSize: 18.0)),
            isDisabled: !isAgeConfirmed,
            onPressed: () {
              Navigator.pushNamed(context, '/auth/submit_step');
            },
          );
  }

  Widget _buildPreviousButton({@required BuildContext context}) {
    String buttonText = localizationService.trans('AUTH.CREATE_ACC.PREVIOUS');

    return OBSecondaryButton(
      isFullWidth: true,
      isLarge: true,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            buttonText,
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )
        ],
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}