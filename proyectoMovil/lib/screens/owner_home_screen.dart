import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../utils/colors.dart'; // Import AppColors
import '../../utils/app_routes.dart'; // Import AppRoutes
import '../../utils/app_exceptions.dart'; // Import AppExceptions

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String? errorMessage;
    // Simulated data that would normally come from API calls
    String reservationsToday = '0';
    String monthlyRevenue = '\$0';
    String activeCourts = '0';
    String newClients = '0';

    try {
      // Simulate fetching data
      // Replace with actual API calls using FieldService or a new DashboardService
      reservationsToday = '12';
      monthlyRevenue = '\$2,450';
      activeCourts = '4';
      newClients = '8';
    } on AppException catch (e) {
      errorMessage = e.message;
      // Optionally show a SnackBar here
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      errorMessage = 'Ocurrió un error inesperado al cargar el resumen.';
      // Optionally show a SnackBar here
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Dueño'),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              if (errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage!), backgroundColor: Colors.red),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null) // Display error message if present
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
            else // Add this else block
              Column( // Wrap the rest of the content in a Column
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Resumen de Negocio',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildSummaryCard('Reservas Hoy', reservationsToday, MdiIcons.calendarCheck, AppColors.primaryBlue),
                      _buildSummaryCard('Ingresos Mensuales', monthlyRevenue, MdiIcons.cash, AppColors.primaryGreen),
                      _buildSummaryCard('Canchas Activas', activeCourts, MdiIcons.soccerField, AppColors.primaryOrange),
                      _buildSummaryCard('Clientes Nuevos', newClients, MdiIcons.accountGroup, AppColors.primaryPurple),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Gestión Rápida',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.9,
                    children: [
                      _buildActionButton(context, 'Agregar Cancha', Icons.add, AppColors.primaryBlue, () => Navigator.pushNamed(context, AppRoutes.createField)),
                      _buildActionButton(context, 'Reservas', Icons.calendar_today, AppColors.primaryGreen, () => Navigator.pushNamed(context, AppRoutes.ownerBookings)),
                      _buildActionButton(context, 'Clientes', Icons.people, AppColors.primaryOrange, () => Navigator.pushNamed(context, AppRoutes.ownerClients)),
                      _buildActionButton(context, 'Reportes', Icons.bar_chart, AppColors.primaryPurple, () => Navigator.pushNamed(context, AppRoutes.ownerReports)),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Próximas Reservas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver Todas',
                          style: TextStyle(color: AppColors.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildReservationItem('Cancha 1', 'Juan Pérez', '18:00 - 20:00'),
                  _buildReservationItem('Cancha 2', 'Carlos Gómez', '19:00 - 21:00'),
                  _buildReservationItem('Cancha 3', 'María Rodríguez', '20:00 - 22:00'),

                  const SizedBox(height: 30),
                  const Text(
                    'Estadísticas Mensuales',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildChartBar(80, 'Lun'),
                              _buildChartBar(120, 'Mar'),
                              _buildChartBar(160, 'Mié'),
                              _buildChartBar(200, 'Jue'),
                              _buildChartBar(180, 'Vie'),
                              _buildChartBar(140, 'Sáb'),
                              _buildChartBar(100, 'Dom'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ingresos por día (\$)',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),
            const Text(
              'Gestión Rápida',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.9,
              children: [
                _buildActionButton(context, 'Agregar Cancha', Icons.add, AppColors.primaryBlue, () => Navigator.pushNamed(context, AppRoutes.createField)),
                _buildActionButton(context, 'Reservas', Icons.calendar_today, AppColors.primaryGreen, () => Navigator.pushNamed(context, AppRoutes.ownerBookings)),
                _buildActionButton(context, 'Clientes', Icons.people, AppColors.primaryOrange, () => Navigator.pushNamed(context, AppRoutes.ownerClients)),
                _buildActionButton(context, 'Reportes', Icons.bar_chart, AppColors.primaryPurple, () => Navigator.pushNamed(context, AppRoutes.ownerReports)),
              ],
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Próximas Reservas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ver Todas',
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildReservationItem('Cancha 1', 'Juan Pérez', '18:00 - 20:00'),
            _buildReservationItem('Cancha 2', 'Carlos Gómez', '19:00 - 21:00'),
            _buildReservationItem('Cancha 3', 'María Rodríguez', '20:00 - 22:00'),

            const SizedBox(height: 30),
            const Text(
              'Estadísticas Mensuales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildChartBar(80, 'Lun'),
                        _buildChartBar(120, 'Mar'),
                        _buildChartBar(160, 'Mié'),
                        _buildChartBar(200, 'Jue'),
                        _buildChartBar(180, 'Vie'),
                        _buildChartBar(140, 'Sáb'),
                        _buildChartBar(100, 'Dom'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ingresos por día (\$)',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Canchas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationItem(String court, String client, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.gray100,
          child: Icon(Icons.sports_soccer, color: AppColors.primaryGreen),
        ),
        title: Text(court, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(client),
        trailing: Text(
          time,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChartBar(double height, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: height / 3,
            width: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
