/// Utilidad para validar correos institucionales del IPN.
///
/// Formato alumno : <inicial_nombre><apellido_paterno><inicial_apellido_materno><4 dígitos>@alumno.ipn.mx
/// Ejemplo        : kcarrillor1900@alumno.ipn.mx
///
/// Formato jefe/admin: cualquier alias válido @ipn.mx
class IpnEmailValidator {
  IpnEmailValidator._();

  static const String _dominioAlumno = '@alumno.ipn.mx';
  static const String _dominioIpn = '@ipn.mx';

  // ── Validación de dominio ────────────────────────────────────────────────

  /// Retorna true si el correo tiene dominio de alumno.
  static bool esCorreoAlumno(String email) =>
      email.trim().toLowerCase().endsWith(_dominioAlumno);

  /// Retorna true si el correo tiene dominio institucional genérico (jefe/admin).
  static bool esCorreoIpn(String email) =>
      email.trim().toLowerCase().endsWith(_dominioIpn);

  // ── Validación de formato del alias ─────────────────────────────────────

  /// Valida que el alias del correo de alumno siga el patrón:
  ///   <inicial_nombre><apellido_paterno><inicial_apellido_materno><4 dígitos>
  ///
  /// Retorna null si es válido, o un mensaje de error en caso contrario.
  static String? validarFormatoAlias(String email) {
    final lower = email.trim().toLowerCase();
    if (!lower.endsWith(_dominioAlumno)) {
      return 'El correo debe terminar en $_dominioAlumno';
    }

    final alias = lower.split('@').first;

    // Patrón: 1+ letras (inicial+apellido), 1 letra (inicial ap. materno),
    // exactamente 4 dígitos al final.
    final regExp = RegExp(r'^[a-záéíóúüñ]{2,}[a-záéíóúüñ][0-9]{4}$');
    if (!regExp.hasMatch(alias)) {
      return 'El formato debe ser: inicial+apellido+inicial+4 dígitos\n'
          'Ejemplo: kcarrillor1900@alumno.ipn.mx';
    }
    return null;
  }

  // ── Validación cruzada con nombre/apellidos ──────────────────────────────

  /// Valida que el alias del correo sea coherente con el nombre y apellidos.
  ///
  /// Reglas (flexibles, ignora acentos y mayúsculas):
  ///   1. El alias debe iniciar con la inicial del primer nombre.
  ///   2. Después de la inicial, debe contener el apellido paterno completo.
  ///   3. Justo después del apellido paterno debe ir la inicial del apellido materno.
  ///   4. Terminar con exactamente 4 dígitos.
  ///
  /// Retorna null si es válido, o un mensaje descriptivo de error.
  static String? validarConNombre({
    required String email,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
  }) {
    if (nombre.trim().isEmpty ||
        apellidoPaterno.trim().isEmpty ||
        apellidoMaterno.trim().isEmpty) {
      return null; // No se puede validar sin datos completos.
    }

    // El alias conserva dígitos; solo se normalizan letras (quitar acentos).
    final alias = _normalizarAliasEmail(email.split('@').first);
    final inicialNombre = _inicialDe(nombre);
    final apPaterno = _normalizarTexto(apellidoPaterno);
    final inicialMaterno = _inicialDe(apellidoMaterno);

    // 1. Debe iniciar con la inicial del nombre.
    if (!alias.startsWith(inicialNombre)) {
      return 'El correo debe iniciar con la inicial de tu nombre ($inicialNombre...)';
    }

    // 2. Después de la inicial debe venir el apellido paterno.
    final despuesInicial = alias.substring(1); // quita inicial nombre
    if (!despuesInicial.startsWith(apPaterno)) {
      return 'El correo debe contener tu apellido paterno después de la inicial\n'
          'Esperado: $inicialNombre$apPaterno...';
    }

    // 3. Después del apellido paterno debe ir la inicial del apellido materno.
    final despuesApPaterno = despuesInicial.substring(apPaterno.length);
    if (!despuesApPaterno.startsWith(inicialMaterno)) {
      return 'Después del apellido paterno debe ir la inicial de tu apellido materno ($inicialMaterno)';
    }

    // 4. Lo restante deben ser exactamente 4 dígitos.
    final sufijo = despuesApPaterno.substring(1);
    if (!RegExp(r'^\d{4}$').hasMatch(sufijo)) {
      return 'El correo debe terminar en exactamente 4 dígitos\n'
          'Ejemplo: ${inicialNombre}${apPaterno}${inicialMaterno}1900@alumno.ipn.mx';
    }

    return null;
  }

  // ── Validación general de formato de email ───────────────────────────────

  /// Valida que sea un email con formato básico correcto.
  static String? validarFormatoGeneral(String email) {
    if (email.trim().isEmpty) return 'Campo requerido';
    final regExp = RegExp(r'^[\w._%+-]+@[\w.-]+\.\w{2,}$');
    if (!regExp.hasMatch(email.trim())) return 'Correo inválido';
    return null;
  }

  // ── Helpers privados ─────────────────────────────────────────────────────

  /// Normaliza texto: minúsculas, sin acentos, solo letras a-z.
  /// Usado para nombres y apellidos (sin dígitos).
  static String _normalizarTexto(String texto) {
    const acentos = 'áéíóúüàèìòùâêîôûäëïöüÿãõ';
    const sinAcento = 'aeiouuaeiouaeiouaeiouÿao';
    var resultado = texto.trim().toLowerCase();
    for (var i = 0; i < acentos.length; i++) {
      resultado = resultado.replaceAll(acentos[i], sinAcento[i]);
    }
    return resultado.replaceAll(RegExp(r'[^a-z]'), '');
  }

  /// Normaliza el alias del correo: minúsculas, sin acentos,
  /// conservando letras Y dígitos (no elimina los 4 números finales).
  static String _normalizarAliasEmail(String alias) {
    const acentos = 'áéíóúüàèìòùâêîôûäëïöüÿãõ';
    const sinAcento = 'aeiouuaeiouaeiouaeiouÿao';
    var resultado = alias.trim().toLowerCase();
    for (var i = 0; i < acentos.length; i++) {
      resultado = resultado.replaceAll(acentos[i], sinAcento[i]);
    }
    return resultado.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String _inicialDe(String texto) =>
      _normalizarTexto(texto).isNotEmpty ? _normalizarTexto(texto)[0] : '';
}
