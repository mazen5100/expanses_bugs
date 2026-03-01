import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expenses_app/Models/expanses.dart';

class NewExpanses extends StatefulWidget {
  const NewExpanses({super.key, required this.onAddExpanses});
  final void Function(Expansesmodel) onAddExpanses;

  @override
  State<NewExpanses> createState() => _NewExpansesState();
}

class _NewExpansesState extends State<NewExpanses> {
  final _titlecontroller = TextEditingController();
  final _amountcontroller = TextEditingController();
  final formatter = DateFormat.yMd();

  Category _selectedCategory = Category.travel;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titlecontroller.dispose();
    _amountcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _titlecontroller,
            maxLength: 50,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountcontroller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No Date Selected'
                            : formatter.format(_selectedDate!),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final firstDate = DateTime(
                          now.year - 1,
                          now.month,
                          now.day,
                        );

                        final pickdata = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: firstDate,
                          lastDate: now,
                        );

                        // 🐞 BUG 1: setState
                        setState(() {
                          _selectedDate = pickdata;
                        });
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              DropdownButton(
                value: _selectedCategory,
                items: Category.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (newvalue) {
                  setState(() {
                    _selectedCategory = newvalue as Category;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final double? enteredAmount = double.tryParse(
                    _amountcontroller.text,
                  );

                  // 🐞 BUG 2:
                  final bool amountisvalid =
                      enteredAmount != null && enteredAmount > 0;

                  if (_titlecontroller.text.trim().isEmpty ||
                      !amountisvalid ||
                      _selectedDate == null) {
                    return;
                  }

                  widget.onAddExpanses(
                    Expansesmodel(
                      title: _titlecontroller.text,
                      amount: enteredAmount!,
                      date: _selectedDate!,
                      category: _selectedCategory,
                    ),
                  );

                  // 🐞 BUG 3: Navigation problem
                  Navigator.pop(
                    context
                  );
                },
                child: const Text('Save Expanses'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
