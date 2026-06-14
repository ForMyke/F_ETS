import 'email_validator.dart';

/// Colección de validadores reutilizables para formularios.
/// Todos retornan null si es válido, o String con el error.
abstract class FormValidators {
  FormValidators._();

  // ── Campos generales ─────────────────────────────────────────────────────

  static String? requerido(String? value, {String campo = 'Campo'}) {
    if (value == null || value.trim().isEmpty) return '$campo requerido';
    return null;
  }

  static String? longitudMinima(String? value, int min) {
    if (value == null || value.length < min) {
      return 'Mínimo $min caracteres';
    }
    return null;
  }

  static String? password(String? value) {
    final req = requerido(value, campo: 'Contraseña');
    if (req != null) return req;
    return longitudMinima(value!, 6);
  }

  static String? confirmarPassword(String? value, String original) {
    final req = requerido(value, campo: 'Confirmación');
    if (req != null) return req;
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? nombre(String? value, {String campo = 'Nombre'}) {
    final req = requerido(value, campo: campo);
    if (req != null) return req;
    if (value!.trim().length < 2) return '$campo inválido';
    return null;
  }

  // ── Correos institucionales ──────────────────────────────────────────────

  /// Valida correo de alumno: dominio + formato alias.
  static String? correoAlumno(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    final formatoGeneral = IpnEmailValidator.validarFormatoGeneral(value);
    if (formatoGeneral != null) return formatoGeneral;
    if (!IpnEmailValidator.esCorreoAlumno(value)) {
      return 'El correo debe terminar en @alumno.ipn.mx';
    }
    return IpnEmailValidator.validarFormatoAlias(value);
  }

  /// Valida correo de alumno cruzado con nombre y apellidos.
  static String? correoAlumnoConNombre({
    required String? value,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
  }) {
    final base = correoAlumno(value);
    if (base != null) return base;
    return IpnEmailValidator.validarConNombre(
      email: value!,
      nombre: nombre,
      apellidoPaterno: apellidoPaterno,
      apellidoMaterno: apellidoMaterno,
    );
  }

  /// Valida correo de jefe/admin: solo dominio @ipn.mx y formato básico.
  static String? correoIpn(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    final formatoGeneral = IpnEmailValidator.validarFormatoGeneral(value);
    if (formatoGeneral != null) return formatoGeneral;
    if (!IpnEmailValidator.esCorreoIpn(value)) {
      return 'El correo debe terminar en @ipn.mx';
    }
    return null;
  }

  // ── Boleta ───────────────────────────────────────────────────────────────

  static String? boleta(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'La boleta debe tener exactamente 10 dígitos';
    }
    return null;
  }
}
