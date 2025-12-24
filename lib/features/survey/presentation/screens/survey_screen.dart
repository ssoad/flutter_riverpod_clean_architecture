import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/presentation/providers/survey_provider.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isFreelancer = false;

  @override
  Widget build(BuildContext context) {
    final surveyState = ref.watch(surveyProvider);
    final checkUsername = ref.watch(checkUsernameUseCaseProvider);

    // Listen for success
    ref.listen(surveyProvider, (previous, next) {
      if (next.status == SurveyStatus.success) {
        AppUtils.showSnackBar(
          context,
          message: 'Survey submitted successfully!',
          backgroundColor: Colors.green,
        );
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else if (next.status == SurveyStatus.failure) {
        AppUtils.showSnackBar(
          context,
          message: next.errorMessage ?? 'Submission failed',
          backgroundColor: Colors.red,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Developer Survey')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Tell us about yourself!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('A demo of complex form validation in Flutter.'),
            const SizedBox(height: 32),
            FormBuilder(
              key: _formKey,
              onChanged: () {
                _formKey.currentState?.save();
                setState(() {
                  _isFreelancer =
                      _formKey.currentState?.value['isFreelancer'] == true;
                });
              },
              child: Column(
                children: [
                  // Username with Async Validator
                  FormBuilderTextField(
                    name: 'username',
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Unique identifier',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(3),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Role Dropdown
                  FormBuilderDropdown<String>(
                    name: 'role',
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.work),
                      filled: true,
                    ),
                    initialValue: 'Frontend',
                    validator: FormBuilderValidators.required(),
                    items:
                        ['Frontend', 'Backend', 'Fullstack', 'DevOps', 'Mobile']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Freelancer Switch
                  FormBuilderSwitch(
                    name: 'isFreelancer',
                    title: const Text('Are you a freelancer?'),
                    initialValue: false,
                    decoration: const InputDecoration(
                      filled: true,
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Conditional Hourly Rate
                  if (_isFreelancer) ...[
                    FormBuilderSlider(
                      name: 'hourlyRate',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.min(10),
                      ]),
                      min: 0,
                      max: 200,
                      divisions: 20,
                      initialValue: 50,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Rate (\$)',
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Favorite Frameworks (Checkbox Group)
                  FormBuilderCheckboxGroup<String>(
                    name: 'feedback',
                    decoration: const InputDecoration(
                      labelText: 'Favorite Frameworks',
                      filled: true,
                      border: InputBorder.none,
                    ),
                    options: const [
                      FormBuilderFieldOption(
                        value: 'Flutter',
                        child: Text('Flutter'),
                      ),
                      FormBuilderFieldOption(
                        value: 'React',
                        child: Text('React'),
                      ),
                      FormBuilderFieldOption(value: 'Vue', child: Text('Vue')),
                      FormBuilderFieldOption(
                        value: 'Angular',
                        child: Text('Angular'),
                      ),
                      FormBuilderFieldOption(
                        value: 'Svelte',
                        child: Text('Svelte'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: surveyState.status == SurveyStatus.submitting
                          ? null
                          : () async {
                              if (_formKey.currentState?.saveAndValidate() ??
                                  false) {
                                final values = _formKey.currentState!.value;
                                final username = values['username'] as String;

                                // Manual Async Check
                                final available = await checkUsername(username);
                                final isAvailable = available.fold(
                                  (l) => false,
                                  (r) => r,
                                );

                                if (!isAvailable) {
                                  if (context.mounted) {
                                    _formKey.currentState?.fields['username']
                                        ?.invalidate(
                                          'Username is already taken',
                                        );
                                  }
                                  return;
                                }

                                ref
                                    .read(surveyProvider.notifier)
                                    .submit(values);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: surveyState.status == SurveyStatus.submitting
                          ? const CircularProgressIndicator()
                          : const Text('Submit Survey'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
