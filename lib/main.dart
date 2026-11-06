import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/qr_generator/data/datasources/qr_local_data_source.dart';
import 'features/qr_generator/data/repositories/qr_repository_impl.dart';
import 'features/qr_generator/domain/repositories/qr_repository.dart';
import 'features/qr_generator/presentation/cubit/qr_cubit.dart';
import 'features/qr_generator/presentation/pages/qr_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate dependencies cleanly (Clean Architecture composition root)
  final QrLocalDataSource localDataSource = const QrLocalDataSourceImpl();
  final QrRepository qrRepository = QrRepositoryImpl(
    localDataSource: localDataSource,
  );

  runApp(QrGeneratorApp(qrRepository: qrRepository));
}

class QrGeneratorApp extends StatelessWidget {
  final QrRepository qrRepository;

  const QrGeneratorApp({super.key, required this.qrRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QrCubit>(
      create: (_) => QrCubit(qrRepository: qrRepository),
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const QrHomePage(),
      ),
    );
  }
}
