import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: FutureBuilder(
        future: Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load categories.'),
            );
          } else {
            return Consumer<CategoryProvider>(
              builder: (ctx, categoryProvider, _) {
                return Column(
                  children: [
                    Expanded(
                      child: categoryProvider.categories.isEmpty
                          ? Center(
                        child: Text(
                          'No categories found.',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                          : ListView.builder(
                        itemCount: categoryProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryProvider.categories[index];
                          return ListTile(
                            title: Text(category.name),
                            subtitle: Text('Type: ${category.type}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => categoryProvider.deleteCategory(category.id),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        child: Text('Add Category'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => _CategoryForm(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class _CategoryForm extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  String? selectedType; // Lưu giá trị đã chọn (Income hoặc Expense)

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    return AlertDialog(
      title: Text('Add Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(labelText: 'Type'),
            items: ['income', 'expense'].map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              selectedType = value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Add'),
          onPressed: () {
            final name = nameController.text;

            if (name.isEmpty || selectedType == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill in all fields')),
              );
              return;
            }

            categoryProvider.addCategory(name, selectedType!).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add category')),
              );
            });

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
