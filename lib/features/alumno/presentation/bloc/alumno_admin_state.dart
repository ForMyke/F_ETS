part of 'alumno_admin_bloc.dart';

abstract class AlumnoAdminState extends Equatable {
  const AlumnoAdminState();

  @override
  List<Object?> get props => [];
}

class AlumnoAdminInitial extends AlumnoAdminState {
  const AlumnoAdminInitial();
}

class AlumnoAdminLoading extends AlumnoAdminState {
  const AlumnoAdminLoading();
}

class AlumnoAdminSuccess extends AlumnoAdminState {
  final List<AlumnoAdminItem> alumnos;
  final List<Map<String, dynamic>> carreras;
  final List<Map<String, dynamic>> planes;
  final String searchQuery;

  const AlumnoAdminSuccess({
    required this.alumnos,
    required this.carreras,
    required this.planes,
    this.searchQuery = '',
  });

  List<AlumnoAdminItem> get filtered {
    if (searchQuery.trim().isEmpty) return alumnos;
    final q = searchQuery.trim().toLowerCase();
    return alumnos.where((a) {
      return a.nombreCompleto.toLowerCase().contains(q) ||
          a.boleta.contains(q) ||
          a.correo.toLowerCase().contains(q);
    }).toList();
  }

  AlumnoAdminSuccess copyWith({
    List<AlumnoAdminItem>? alumnos,
    List<Map<String, dynamic>>? carreras,
    List<Map<String, dynamic>>? planes,
    String? searchQuery,
  }) {
    return AlumnoAdminSuccess(
      alumnos: alumnos ?? this.alumnos,
      carreras: carreras ?? this.carreras,
      planes: planes ?? this.planes,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [alumnos, carreras, planes, searchQuery];
}

class AlumnoAdminFailure extends AlumnoAdminState {
  final String message;
  const AlumnoAdminFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
