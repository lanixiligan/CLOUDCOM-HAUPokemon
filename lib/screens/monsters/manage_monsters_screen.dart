import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../../services/api_service.dart';

class ManageMonstersScreen extends StatefulWidget {
  const ManageMonstersScreen({super.key});

  @override
  State<ManageMonstersScreen> createState() => _ManageMonstersScreenState();
}

class _ManageMonstersScreenState extends State<ManageMonstersScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  List<dynamic> _monsters = [];
  bool _isLoading = false;
  int? _editingId;

  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  final Color monsterRed = const Color(0xFFC62828);
  final Color darkSlate = const Color(0xFF263238);

  @override
  void initState() {
    super.initState();
    _refreshMonsters();
  }

  Future<void> _refreshMonsters() async {
    setState(() => _isLoading = true);
    // Hardcoded coords for refresh, matches your previous setup
    final results = await _api.detectMonsters(15.1636, 120.5860); 
    setState(() {
      _monsters = results;
      _isLoading = false;
    });
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final double? lat = double.tryParse(_latController.text);
    final double? lng = double.tryParse(_lngController.text);

    if (lat == null || lng == null) return;

    setState(() => _isLoading = true);
    Navigator.pop(context); 

    bool success;
    if (_editingId == null) {
      success = await _api.addMonster(_nameController.text, lat, lng);
    } else {
      success = await _api.updateMonster(_editingId!, _nameController.text, lat, lng);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Registry Updated" : "Database Error: Check Server Logs"),
          backgroundColor: success ? Colors.green : monsterRed,
        ),
      );
      _refreshMonsters();
    }
  }

  void _handleDelete(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("TERMINATE ENTITY?"),
        content: const Text("Permanent removal from monsterstbl."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text("DELETE", style: TextStyle(color: monsterRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await _api.deleteMonster(id);
      if (mounted) {
        _refreshMonsters();
      }
    }
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))] : [],
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, size: 18),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
    );
  }

  void _prepareEdit(dynamic monster) {
    setState(() {
      _editingId = monster['id'];
      _nameController.text = monster['monster_name'];
      // IMPORTANT: Update these keys to match what your API returns
      _latController.text = (monster['spawn_latitude'] ?? monster['latitude']).toString();
      _lngController.text = (monster['spawn_longitude'] ?? monster['longitude']).toString();
    });
    _showFormSheet();
  }

  void _clearForm() {
    _editingId = null;
    _nameController.clear();
    _latController.clear();
    _lngController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text("MONSTER REGISTRY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: darkSlate,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(color: darkSlate, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32))),
            child: Text("${_monsters.length} ENTITIES REGISTERED", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: monsterRed))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _monsters.length,
                  itemBuilder: (context, index) => _buildMonsterTile(_monsters[index]),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: monsterRed,
        onPressed: () { _clearForm(); _showFormSheet(); },
        label: const Text("ADD NEW MONSTER"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonsterTile(dynamic monster) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.catching_pokemon, color: monsterRed),
        title: Text(monster['monster_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        // Adjusted subtitle to look for the SQL column names
        subtitle: Text("LAT: ${monster['spawn_latitude'] ?? monster['latitude']} / LNG: ${monster['spawn_longitude'] ?? monster['longitude']}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _prepareEdit(monster)),
            IconButton(icon: Icon(Icons.delete_sweep_outlined, color: monsterRed), onPressed: () => _handleDelete(monster['id'])),
          ],
        ),
      ),
    );
  }

  void _showFormSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_editingId == null ? "NEW REGISTRATION" : "EDIT REGISTRATION", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 20),
              _buildField(_nameController, "Monster Name", Icons.badge),
              Row(
                children: [
                  Expanded(child: _buildField(_latController, "Lat", Icons.location_on, isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_lngController, "Lng", Icons.explore, isNumber: true)),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: darkSlate, foregroundColor: Colors.white),
                onPressed: _handleSubmit, 
                child: const Text("SAVE TO MONSTERTBL")
              )),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}