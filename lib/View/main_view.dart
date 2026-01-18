import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rampi_mapeador/Controller/navigation.dart';
import 'package:rampi_mapeador/Model/rampa_class.dart';
import 'package:rampi_mapeador/services/supabase_service.dart';
import 'package:rampi_mapeador/View/login_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rampi_mapeador/features/rampa/presentation/controllers/add_rampa_controller.dart';
import 'package:rampi_mapeador/View/widgets/card.dart';
import 'package:rampi_mapeador/View/widgets/map_widget.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  bool get isLoggedIn => SupabaseService.getCurrentUser() != null;

  void _checkAuthAndNavigate(int index) {
    final Controller c = Get.find();

    if (index == 0) {
      // Mapa sempre acessível
      c.index_tab.value = index;
      c.update();
    } else {
      // Outras abas requerem login
      if (isLoggedIn) {
        c.index_tab.value = index;
        c.update();
      } else {
        _showLoginDialog();
      }
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white.withOpacity(0.95),
          title: Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFF0191E2)),
              SizedBox(width: 10),
              Text(
                'Login necessário',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            'Faça login para adicionar rampas e ganhar créditos!',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                ).then((_) => setState(() {}));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0191E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Fazer Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreditsDialog() {
    final Controller c = Get.find();
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white.withOpacity(0.95),
          title: Row(
            children: [
              Icon(Icons.stars, color: Colors.amber),
              SizedBox(width: 10),
              Text(
                'Meus Créditos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0191E2).withOpacity(0.2),
                      Color(0xFF0191E2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(0xFF0191E2).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${c.userPoints}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0191E2),
                      ),
                    ),
                    Text(
                      'créditos disponíveis',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Troque seus créditos por produtos de parceiros em breve!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0191E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? Color(0xFF0191E2)).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color ?? Color(0xFF0191E2),
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> status = [
      // Mapa como primeira aba
      Padding(
        padding: const EdgeInsets.all(0),
        child: MapWidget(),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: isLoggedIn
              ? FutureBuilder<List<Map<String, dynamic>>>(
                  future: SupabaseService.fetchUserRampas(
                    userId: SupabaseService.getCurrentUser()!.id,
                    status: 'assessment',
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done &&
                        !snapshot.hasData) {
                      return Center(
                        child: Text('Nenhuma rampa cadastrada.'),
                      );
                    }
                    final rampas = snapshot.data ?? [];
                    return RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.builder(
                          itemCount: rampas.length,
                          itemBuilder: (context, index) {
                            final rampa = rampas[index];
                            return WhiteCard(
                                Rampa(
                                  coordenadas: [
                                    rampa['latitude'],
                                    rampa['longitude'],
                                  ],
                                  dataAdicionado: rampa['data_adicionado'],
                                  inclinacao: rampa['inclinacao'],
                                  condicao: rampa['condicao'],
                                  foto: rampa['foto'],
                                  id: rampa['id'].toString(),
                                ),
                                false);
                          }),
                    );
                  })
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Faça login para ver suas rampas',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )),
      Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: isLoggedIn
              ? FutureBuilder<List<Map<String, dynamic>>>(
                  future: SupabaseService.fetchUserRampas(
                    userId: SupabaseService.getCurrentUser()!.id,
                    status: 'review',
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done &&
                        !snapshot.hasData) {
                      return Center(
                        child: Text('Nenhuma rampa cadastrada.'),
                      );
                    }
                    final rampas = snapshot.data ?? [];
                    return RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.builder(
                          itemCount: rampas.length,
                          itemBuilder: (context, index) {
                            final rampa = rampas[index];
                            return WhiteCard(
                                Rampa(
                                  coordenadas: [
                                    rampa['latitude'],
                                    rampa['longitude'],
                                  ],
                                  dataAdicionado: rampa['data_adicionado'],
                                  inclinacao: rampa['inclinacao'],
                                  condicao: rampa['condicao'],
                                  foto: rampa['foto'],
                                  id: rampa['id'].toString(),
                                ),
                                true);
                          }),
                    );
                  })
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Faça login para ver suas rampas',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )),
      Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          child: isLoggedIn
              ? FutureBuilder<List<Map<String, dynamic>>>(
                  future: SupabaseService.fetchUserRampas(
                    userId: SupabaseService.getCurrentUser()!.id,
                    status: 'approved',
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done &&
                        !snapshot.hasData) {
                      return Center(
                        child: Text('Nenhuma rampa cadastrada.'),
                      );
                    }
                    final rampas = snapshot.data ?? [];
                    return RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.builder(
                          itemCount: rampas.length,
                          itemBuilder: (context, index) {
                            final rampa = rampas[index];
                            return WhiteCard(
                                Rampa(
                                  coordenadas: [
                                    rampa['latitude'],
                                    rampa['longitude'],
                                  ],
                                  dataAdicionado: rampa['data_adicionado'],
                                  inclinacao: rampa['inclinacao'],
                                  condicao: rampa['condicao'],
                                  foto: rampa['foto'],
                                  id: rampa['id'].toString(),
                                ),
                                false);
                          }),
                    );
                  })
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Faça login para ver suas rampas',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )),
    ];
    final Controller c = Get.find();
    return Obx(() => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          drawer: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Drawer(
                  backgroundColor: Colors.white.withOpacity(0.85),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      Container(
                        height: 200,
                        padding: EdgeInsets.only(
                            top: 50, left: 20, right: 20, bottom: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF0191E2).withOpacity(0.8),
                              Color(0xFF0191E2).withOpacity(0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isLoggedIn) ...[
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${c.userName.value} ${c.userLastName.value}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.stars,
                                            color: Colors.amber, size: 20),
                                        SizedBox(width: 6),
                                        Text(
                                          '${c.userPoints} créditos',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Icon(Icons.accessibility_new,
                                  size: 50, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                'Rampi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Acessibilidade para todos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      if (!isLoggedIn) ...[
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF0191E2).withOpacity(0.1),
                                  Color(0xFF0191E2).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF0191E2).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Color(0xFF0191E2), size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Ganhe Créditos!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0191E2),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Cadastre rampas e ganhe créditos para trocar em produtos de parceiros.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildGlassListTile(
                          icon: Icons.login,
                          title: 'Fazer Login',
                          subtitle: 'Para adicionar rampas',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            ).then((_) => setState(() {}));
                          },
                        ),
                      ] else ...[
                        _buildGlassListTile(
                          icon: Icons.stars,
                          title: 'Meus Créditos',
                          subtitle: 'Trocar por produtos',
                          onTap: () {
                            Navigator.pop(context);
                            _showCreditsDialog();
                          },
                        ),
                        _buildGlassListTile(
                          icon: Icons.wheelchair_pickup,
                          title: 'Minhas Rampas',
                          subtitle: 'Ver cadastros',
                          onTap: () {
                            Navigator.pop(context);
                            _checkAuthAndNavigate(1);
                          },
                        ),
                        Divider(
                            height: 30,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16),
                        _buildGlassListTile(
                          icon: Icons.exit_to_app,
                          title: 'Sair',
                          subtitle: 'Fazer logout',
                          color: Colors.red.shade400,
                          onTap: () {
                            SupabaseService.signOut();
                            c.isLogged.value = false;
                            setState(() {});
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logout realizado com sucesso'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ],
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Ajude a construir um mundo mais acessível! 🦽',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: status[c.index_tab.value],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: c.index_tab.value,
                    onTap: (index) {
                      _checkAuthAndNavigate(index);
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.map_outlined),
                        activeIcon: Icon(Icons.map),
                        label: 'Explorar',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.pending_outlined),
                        activeIcon: Icon(Icons.pending),
                        label: 'Pendentes',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.hourglass_empty_outlined),
                        activeIcon: Icon(Icons.hourglass_empty),
                        label: 'Análise',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.check_circle_outline),
                        activeIcon: Icon(Icons.check_circle),
                        label: 'Aprovadas',
                      ),
                    ],
                    selectedItemColor: Color(0xFF0191E2),
                    unselectedItemColor: Colors.black54,
                    selectedFontSize: 12,
                    unselectedFontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF0191E2).withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    if (!isLoggedIn) {
                      _showLoginDialog();
                      return;
                    }

                    final user = SupabaseService.getCurrentUser();
                    if (user == null) return;

                    final controller =
                        ref.read(addRampaControllerProvider.notifier);

                    await controller.addRampaFlow(userId: user.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Rampa enviada (se houver foto).')),
                    );
                  },
                  backgroundColor: Color(0xFF0191E2).withOpacity(0.9),
                  elevation: 0,
                  icon: Icon(Icons.add_location_alt, color: Colors.white),
                  label: Text(
                    'Adicionar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
