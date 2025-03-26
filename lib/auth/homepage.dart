// auth/homepage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Medicine> medicines = []; // Lista começa vazia

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Old Usudrio!'),
      ),
      body: medicines.isEmpty
          ? Center(
        child: Text(
          'Nenhum remédio cadastrado\nClique no botão + para adicionar',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final medicine = medicines[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(medicine.name,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Próxima Dose: ${medicine.nextDose.format(context)}\n'
                      'Dosagem: ${medicine.dosage}\n'
                      'Quantidade diária: ${medicine.dailyAmount}x'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    medicines.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _navigateToAddMedicineScreen(context);
        },
      ),
    );
  }

  void _navigateToAddMedicineScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMedicineScreen()),
    );

    if (result != null) {
      setState(() {
        medicines.add(result);
      });
    }
  }
}

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  int _dailyAmount = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Remédio')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome do Remédio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do remédio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'Dosagem'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a dosagem';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Horário: ${_time.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _time = selectedTime;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              Text('Quantidade Diária:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [1, 2, 3].map((number) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChoiceChip(
                      label: Text(number.toString()),
                      selected: _dailyAmount == number,
                      onSelected: (selected) {
                        setState(() {
                          _dailyAmount = number;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                child: Text('Salvar'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, Medicine(
                      name: _nameController.text,
                      dosage: _dosageController.text,
                      nextDose: _time,
                      dailyAmount: _dailyAmount,
                    ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Medicine {
  final String name;
  final String dosage;
  final TimeOfDay nextDose;
  final int dailyAmount;

  Medicine({
    required this.name,
    required this.dosage,
    required this.nextDose,
    required this.dailyAmount,
  });
}