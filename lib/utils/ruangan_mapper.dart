class RuanganMapper {
  static const Map<String, String> _ruangan = {
    '1': 'Ruang Administrasi',
    '2': 'Ruang Kepala Dinas',
    '3': 'Ruang Server',
    '4': 'Gudang Inventaris',
    '5': 'Ruang Rapat',
  };

  static String getNama(int id) {
    return _ruangan[id] ?? 'Tidak diketahui';
  }
}
