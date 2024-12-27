// category_screen.dart
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedTab = 0; // 0 for Expense, 1 for Income

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Category List"),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewCategoryScreen()),
              );
            },
            child: Text(
              "Add New",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs for Expense and Income
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton("Expense", 0),
              _buildTabButton("Income", 1),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Replace with your dynamic count
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    Icons.category,
                    color: _getIconColor(index),
                  ),
                  title: Text(
                    _selectedTab == 0 ? "Expense Category $index" : "Income Category $index",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper for tab buttons
  Widget _buildTabButton(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: _selectedTab == index ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Helper to define icon color
  Color _getIconColor(int index) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
}

// new_category_screen.dart
class NewCategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Category"),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Save",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Category Name",
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              "Icon",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Wrap(
              spacing: 10,
              children: List.generate(
                10,
                    (index) => Icon(
                  Icons.category,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Color",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Wrap(
              spacing: 10,
              children: List.generate(
                10,
                    (index) => Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: Colors.primaries[index % Colors.primaries.length],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
