import 'package:blog_posting/riverpod_mvvm_api/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class View1 extends ConsumerWidget {
  const View1({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewWatch = ref.watch(viewModelProvider);
    final viewRead = ref.read(viewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('riverpod!'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          viewWatch.when(
            data: (data) => Text(data.toJson().toString()),
            error: (error, stackTrace) => Text('에러: $error'),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
