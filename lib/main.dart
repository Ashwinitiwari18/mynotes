import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/helpers/loding/loding_screen.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';
import 'package:mynotes/views/login_veiw.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdatenoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedout) {
          return const LoginVeiw();
        } else if (state is AuthStateRegistering) {
          return const RegisterVeiw();
        } else {
          return const Scaffold(body: CircularProgressIndicator());
        }
      },
    );
  }
}

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;
//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Texting Bloc'),
//         ),
//         body:
//             BlocConsumer<CounterBloc, CounterState>(listener: (context, state) {
//           _controller.clear();
//         }, builder: (context, state) {
//           final invalidValue =
//               (state is CounterStateInvalideNumber) ? state.value : '';
//           return Column(
//             children: [
//               Text('Current Value => ${state.value}'),
//               Visibility(
//                 child: Text('CounterState InvalidValue $invalidValue'),
//                 visible: state is CounterStateInvalideNumber,
//               ),
//               TextField(
//                 controller: _controller,
//                 decoration:
//                     const InputDecoration(hintText: 'Enter a number here'),
//                 keyboardType: TextInputType.number,
//               ),
//               Row(
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       context.read<CounterBloc>().add(
//                             DecrementEvent(_controller.text),
//                           );
//                     },
//                     child: const Text('-'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       context.read<CounterBloc>().add(
//                             IncrementEvent(_controller.text),
//                           );
//                     },
//                     child: const Text('+'),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalideNumber extends CounterState {
  final String currValue;
  final int prevValue;
  const CounterStateInvalideNumber({
    required this.currValue,
    required this.prevValue,
  }) : super(prevValue);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(
      (event, emit) {
        final interger = int.tryParse(event.value);
        if (interger == null) {
          emit(
            CounterStateInvalideNumber(
              currValue: event.value,
              prevValue: state.value,
            ),
          );
        } else {
          emit(
            CounterStateValid(state.value + interger),
          );
        }
      },
    );
    on<DecrementEvent>(
      (event, emit) {
        final interger = int.tryParse(event.value);
        if (interger == null) {
          emit(
            CounterStateInvalideNumber(
              currValue: event.value,
              prevValue: state.value,
            ),
          );
        } else {
          emit(
            CounterStateValid(
              state.value - interger,
            ),
          );
        }
      },
    );
  }
}
