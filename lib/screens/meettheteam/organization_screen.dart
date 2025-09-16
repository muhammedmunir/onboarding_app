import 'package:flutter/material.dart';

class OrganizationScreen extends StatelessWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meet The Team',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(224, 124, 124, 1),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Organization Chart',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildLeaderSection(),
            const SizedBox(height: 20),
            _buildDivider(),
            const SizedBox(height: 20),
            _buildManagementTeam(),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 1,
      color: Colors.grey,
    );
  }

  Widget _buildLeaderSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OrganizationItem(
          name: 'Datuk Ir. Megat Jalaluddin Bin',
          children: [
            _OrganizationItem(name: 'Megat Hassan'),
            _OrganizationItem(name: 'President/Actual Regional'),
            _OrganizationItem(name: 'Executor (ECC)'),
          ],
        ),
        SizedBox(height: 16),
        _OrganizationItem(
          name: 'Azlan Bin Ahmad',
          position: 'Chief Information Officer (CIO)',
        ),
        SizedBox(height: 16),
        _OrganizationItem(
          name: 'Nik Sofizan Bin Nik Yusuf',
          position: 'Head Center of Delivery & Operation Services',
        ),
        SizedBox(height: 16),
        _OrganizationItem(
          name: 'Azlul Shkib Arsian Bin Zaghiol',
          position: 'Chief Information Officer (CIO)',
        ),
        SizedBox(height: 16),
        _OrganizationItem(
          name: 'İsfaruzi Bin Ismail',
          position: 'Lead Enterprise Solution (Non-SAPI)',
        ),
      ],
    );
  }

  Widget _buildManagementTeam() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OrganizationItem(
          name: 'Mohammad Azrulnizam Bin Kamaludin',
          position: 'Manager (Enterprise Mobility Solution)',
          children: [
            _OrganizationItem(
              name: 'Teng Jun Slong',
              position: 'Executive (EMS)',
            ),
            _OrganizationItem(
              name: 'Suguma Ambihai A/P Balachantar',
              position: 'Executive (EMS)',
            ),
          ],
        ),
        SizedBox(height: 16),
        _OrganizationItem(
          name: 'Adibah Binti Khaled',
          position: 'Manager (Enterprise Content Management)',
        ),
        SizedBox(height: 16),
        _OrganizationItem(
          name: 'Nurelahajaraha Binti Mahamed Ramly',
          position: 'Manager (Commercial off-the-shelf)',
          children: [
            _OrganizationItem(
              name: 'Muhammad Hasif Bin Salim',
              position: 'Executive (COTS)',
            ),
            _OrganizationItem(
              name: 'Nur\'Ainin Binti Md Jani',
              position: 'Executive (COTS)',
            ),
          ],
        ),
        SizedBox(height: 16),
        _OrganizationItem(
          name: 'Mazran Noor Bin Mohamad Zain',
          position: 'Manager (Enterprise Portal Solution)',
          children: [
            _OrganizationItem(
              name: 'Nurasmidar Binti Sualb',
              position: 'Executive (EPS)',
            ),
            _OrganizationItem(
              name: 'Wan Nashrul Syafiq Bin Wan Roshdee',
              position: 'Executive (EPS)',
            ),
          ],
        ),
        SizedBox(height: 16),
        _OrganizationItem(
          name: 'Noor Haffizah Binti Abu',
          position: 'Manager (Business Process Management)',
          children: [
            _OrganizationItem(
              name: 'Nurul Aimi Athirah Binti Juarimi',
              position: 'Executive (BPM)',
            ),
            _OrganizationItem(
              name: 'Muhammad Hisham Bin Ahmad Asri',
              position: 'Executive (BPM)',
            ),
          ],
        ),
      ],
    );
  }
}

class _OrganizationItem extends StatelessWidget {
  final String name;
  final String? position;
  final List<_OrganizationItem> children;

  const _OrganizationItem({
    required this.name,
    this.position,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: children.isNotEmpty
            ? const Border(
                left: BorderSide(color: Colors.grey, width: 1.0),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (position != null)
                  TextSpan(
                    text: '\n$position',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...children.map((child) => child),
          ],
        ],
      ),
    );
  }
}