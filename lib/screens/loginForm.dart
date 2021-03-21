import 'dart:math';

import 'package:caladrius/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

//TODO Add switch to add addtional basic auth

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  var lastUserName = 'admin';
  var lastPassword = '';
  var urlToCouchDb = 'http://localhost:5984';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (bcontext) => LoginBloc(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (bcontext, state) {
          if (state is LoginOk) {
            Navigator.of(bcontext).pushReplacementNamed('/dashboard');
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (bcontext, state) {
            return Center(
              child: buildContent(bcontext, state),
            );
          },
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context, LoginState state) {
    //Ok is handled in the listener inside build
    if (state is LoginInitial || state is LoginFailed) {
      var corsError = false;
      if (state is LoginFailed) {
        corsError = state.maybeCors;
      }
      return buildForm(context, state is LoginFailed, corsError);
    } else if (state is LoginRunning) {
      return CircularProgressIndicator();
    } else {
      return Text('This is not the text you are looking for');
    }
  }

  Widget buildForm(BuildContext context, bool error, bool maybeCors) {
    final maxWidth = MediaQuery.of(context).size.width;
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: min(500, maxWidth),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login to CouchDB',
                style: Theme.of(context).textTheme.headline4,
              ),
              TextFormField(
                decoration: InputDecoration(
                  helperText: 'Server url',
                ),
                initialValue: urlToCouchDb,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'URL required';
                  }
                  return null;
                },
                onSaved: (value) {
                  urlToCouchDb = value ?? '';
                },
              ),
              TextFormField(
                initialValue: lastUserName,
                decoration: InputDecoration(
                  helperText: 'User name',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'User name required';
                  }
                  return null;
                },
                onSaved: (value) {
                  lastUserName = value ?? '';
                },
              ),
              TextFormField(
                obscureText: true,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                  helperText: 'Password',
                  errorText: error ? getError(maybeCors) : null,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Password required';
                  }
                  return null;
                },
                onSaved: (value) {
                  lastPassword = value ?? '';
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        //Let bloc request a login
                        BlocProvider.of<LoginBloc>(context).add(LoginRequest(
                            urlToCouchDb, lastUserName, lastPassword));
                      }
                    },
                    child: Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/cors');
                    },
                    child: Text('Login issue?'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getError(bool corsError) {
    if (corsError) {
      return 'Maybe CORS error, see help';
    }
    return 'User or password wrong';
  }
}
