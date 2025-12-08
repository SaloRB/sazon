import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sazon_recetas/core/core.dart';
import 'package:sazon_recetas/features/features.dart';

class RecipeFormPage extends StatelessWidget {
  final RecipeDetail? initialDetail;

  const RecipeFormPage({super.key, this.initialDetail});

  @override
  Widget build(BuildContext context) {
    final apiClient = context.read<ApiClient>();
    final repository = RecipesRepository(apiClient: apiClient);

    final isEditMode = initialDetail != null;

    return BlocProvider<RecipeFormCubit>(
      create: (_) => isEditMode
          ? RecipeFormCubit.edit(
              repository: repository,
              initialDetail: initialDetail!,
            )
          : RecipeFormCubit.create(repository: repository),
      child: _RecipeFormView(initialDetail: initialDetail),
    );
  }
}

class _RecipeFormView extends StatefulWidget {
  final RecipeDetail? initialDetail;

  const _RecipeFormView({required this.initialDetail});

  @override
  State<_RecipeFormView> createState() => _RecipeFormViewState();
}

class _RecipeFormViewState extends State<_RecipeFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _servingsController;

  RecipeDifficulty? _selectedDifficulty;

  // Dynamic lists for ingredients and steps
  late List<IngredientInput> _ingredients;
  late List<StepInput> _steps;

  @override
  void initState() {
    super.initState();

    final detail = widget.initialDetail;

    _titleController = TextEditingController(text: detail?.recipe.title ?? '');
    _descriptionController = TextEditingController(
      text: detail?.recipe.description ?? '',
    );
    _prepTimeController = TextEditingController(
      text: detail != null ? detail.recipe.prepTimeMinutes?.toString() : '',
    );
    _cookTimeController = TextEditingController(
      text: detail != null ? detail.recipe.cookTimeMinutes?.toString() : '',
    );
    _servingsController = TextEditingController(
      text: detail != null ? detail.recipe.servings?.toString() : '',
    );

    _selectedDifficulty = detail?.recipe.difficulty;

    if (detail != null) {
      _ingredients = detail.ingredients
          .map(
            (ing) => IngredientInput(
              name: ing.name,
              quantity: ing.quantity,
              position: ing.position,
            ),
          )
          .toList();

      _steps = detail.steps
          .map(
            (step) => StepInput(
              stepNumber: step.stepNumber,
              description: step.description,
            ),
          )
          .toList();
    } else {
      _ingredients = [];
      _steps = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients = [
        ..._ingredients,
        IngredientInput(name: '', quantity: null, position: null),
      ];
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients = List.of(_ingredients)..removeAt(index);
    });
  }

  void _updateIngredientName(int index, String value) {
    setState(() {
      final old = _ingredients[index];
      _ingredients[index] = IngredientInput(
        name: value,
        quantity: old.quantity,
        position: old.position,
      );
    });
  }

  void _updateIngredientQuantity(int index, String value) {
    setState(() {
      final old = _ingredients[index];
      _ingredients[index] = IngredientInput(
        name: old.name,
        quantity: value.isEmpty ? null : value,
        position: old.position,
      );
    });
  }

  void _addStep() {
    setState(() {
      final nextNumber = _steps.length + 1;
      _steps = [..._steps, StepInput(stepNumber: nextNumber, description: '')];
    });
  }

  void _removeStep(int index) {
    setState(() {
      final mutable = List<StepInput>.of(_steps)..removeAt(index);
      // Reasign number from 1
      _steps = List.generate(
        mutable.length,
        (i) =>
            StepInput(stepNumber: i + 1, description: mutable[i].description),
      );
    });
  }

  void _updateStepDescription(int index, String value) {
    setState(() {
      final old = _steps[index];
      _steps[index] = StepInput(stepNumber: old.stepNumber, description: value);
    });
  }

  Future<void> _onSavePressed(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prepTime = int.tryParse(_prepTimeController.text.trim());
    final cookTime = int.tryParse(_cookTimeController.text.trim());
    final servings = int.tryParse(_servingsController.text.trim());

    // Ingredient cleanup: remove empty names
    final cleanedIngredients = _ingredients
        .where((i) => i.name.trim().isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => IngredientInput(
            name: entry.value.name.trim(),
            quantity: entry.value.quantity?.trim().isEmpty ?? true
                ? null
                : entry.value.quantity!.trim(),
            position: entry.key + 1,
          ),
        )
        .toList();

    // Steps cleanup: remove empty descriptions
    final cleanedSteps = _steps
        .where((s) => s.description.trim().isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => StepInput(
            stepNumber: entry.key + 1,
            description: entry.value.description.trim(),
          ),
        )
        .toList();

    final isEdit = widget.initialDetail != null;
    final cubit = context.read<RecipeFormCubit>();

    if (!isEdit) {
      final input = CreateRecipeInput(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        difficulty: _selectedDifficulty,
        prepTimeMinutes: prepTime,
        cookTimeMinutes: cookTime,
        servings: servings,
        ingredients: cleanedIngredients,
        steps: cleanedSteps,
      );
      await cubit.submitCreate(input);
    } else {
      final input = UpdateRecipeInput(
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        difficulty: _selectedDifficulty,
        prepTimeMinutes: prepTime,
        cookTimeMinutes: cookTime,
        servings: servings,
        ingredients: cleanedIngredients.isEmpty ? null : cleanedIngredients,
        steps: cleanedSteps.isEmpty ? null : cleanedSteps,
      );
      await cubit.submitUpdate(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialDetail != null;

    return BlocListener<RecipeFormCubit, RecipeFormState>(
      listener: (context, state) {
        if (state.status == RecipeFormStatus.success && state.result != null) {
          Navigator.of(context).pop(state.result);
        } else if (state.status == RecipeFormStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(isEdit ? 'Editar Receta' : 'Crear Receta')),
        body: BlocBuilder<RecipeFormCubit, RecipeFormState>(
          builder: (context, state) {
            final isSaving = state.status == RecipeFormStatus.saving;
            final textTheme = Theme.of(context).textTheme;

            return AbsorbPointer(
              absorbing: isSaving,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Field
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Título',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El título es obligatorio.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Description Field
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),

                          // Difficulty Dropdown
                          DropdownButtonFormField<RecipeDifficulty>(
                            initialValue: _selectedDifficulty,
                            decoration: const InputDecoration(
                              labelText: 'Dificultad',
                            ),
                            items: RecipeDifficulty.values.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text(d.label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Times
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _prepTimeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tiempo de preparación (min)',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _cookTimeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tiempo de cocción (min)',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Servings
                          TextFormField(
                            controller: _servingsController,
                            decoration: const InputDecoration(
                              labelText: 'Porciones',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),

                          // Ingredients Input
                          Text(
                            'Ingredientes',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              for (var i = 0; i < _ingredients.length; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          initialValue: _ingredients[i].name,
                                          decoration: const InputDecoration(
                                            hintText: 'Ingrediente',
                                          ),
                                          onChanged: (value) =>
                                              _updateIngredientName(i, value),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          initialValue:
                                              _ingredients[i].quantity ?? '',
                                          decoration: const InputDecoration(
                                            hintText: 'Cantidad (opcional)',
                                          ),
                                          onChanged: (value) =>
                                              _updateIngredientQuantity(
                                                i,
                                                value,
                                              ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeIngredient(i),
                                        icon: Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ),
                              TextButton.icon(
                                onPressed: _addIngredient,
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar ingrediente'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Steps
                          Text(
                            'Pasos',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              for (var i = 0; i < _steps.length; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('${_steps[i].stepNumber}. '),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: _steps[i].description,
                                          decoration: const InputDecoration(
                                            hintText: 'Descripción del paso',
                                          ),
                                          maxLines: null,
                                          onChanged: (value) =>
                                              _updateStepDescription(i, value),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeStep(i),
                                        icon: Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ),
                              TextButton.icon(
                                onPressed: _addStep,
                                icon: Icon(Icons.add),
                                label: const Text('Agregar paso'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),

                  if (isSaving)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black26,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: BlocBuilder<RecipeFormCubit, RecipeFormState>(
          builder: (context, state) {
            final isSaving = state.status == RecipeFormStatus.saving;

            return FloatingActionButton.extended(
              onPressed: isSaving ? null : () => _onSavePressed(context),
              backgroundColor: AppColors.primary,
              icon: Icon(Icons.save),
              label: Text(isEdit ? 'Guardar cambios' : 'Crear receta'),
            );
          },
        ),
      ),
    );
  }
}
