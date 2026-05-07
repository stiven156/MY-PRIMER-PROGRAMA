import 'package:gym_app/core/models/exercise_model.dart';

class ExercisesData {
  static const List<ExerciseModel> all = [
    // ── CHEST ────────────────────────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_bench_press',
      name: 'Press de Banca',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
      equipment: Equipment.barbell,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.strength,
      caloriesPerMinute: 8.0,
      instructions:
          '1. Acuéstate en el banco con los pies apoyados en el suelo.\n'
          '2. Agarra la barra con un agarre ligeramente más ancho que los hombros.\n'
          '3. Desciende la barra controladamente hasta el pecho.\n'
          '4. Empuja explosivamente hasta la posición inicial.',
      tips: [
        'Mantén los omóplatos retraídos durante todo el movimiento.',
        'No reboces la barra en el pecho.',
        'Los pies siempre apoyados en el suelo.',
      ],
    ),
    ExerciseModel(
      id: 'ex_incline_press',
      name: 'Press Inclinado con Mancuernas',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
      equipment: Equipment.dumbbell,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.strength,
      caloriesPerMinute: 7.0,
      instructions:
          '1. Ajusta el banco a 30-45 grados.\n'
          '2. Siéntate con una mancuerna en cada mano a la altura del pecho.\n'
          '3. Empuja hacia arriba y ligeramente hacia adentro.\n'
          '4. Baja controladamente.',
      tips: [
        'No permitas que los codos caigan por debajo de los hombros.',
        'Mantén una leve curvatura lumbar natural.',
      ],
    ),
    ExerciseModel(
      id: 'ex_chest_fly',
      name: 'Aperturas con Mancuernas',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.shoulders],
      equipment: Equipment.dumbbell,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 6.0,
      instructions:
          '1. Acuéstate en el banco plano con mancuernas.\n'
          '2. Extiende los brazos con codos ligeramente flexionados.\n'
          '3. Abre los brazos hasta sentir el estiramiento en el pecho.\n'
          '4. Cierra los brazos como abrazando un árbol.',
      tips: ['Enfócate en la contracción del pecho, no en el peso.'],
    ),
    ExerciseModel(
      id: 'ex_dips',
      name: 'Fondos en Paralelas',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
      equipment: Equipment.pullupBar,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.calisthenics,
      caloriesPerMinute: 9.0,
      isBodyweight: true,
      instructions:
          '1. Apóyate en las barras con brazos extendidos.\n'
          '2. Inclínate ligeramente hacia adelante para enfatizar el pecho.\n'
          '3. Desciende hasta que los codos estén a 90 grados.\n'
          '4. Empuja hasta la posición inicial.',
      tips: ['Inclinarte más hacia adelante activa más el pecho.'],
    ),
    ExerciseModel(
      id: 'ex_cable_crossover',
      name: 'Cruce de Poleas',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.shoulders],
      equipment: Equipment.cables,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 6.5,
      instructions:
          '1. Ajusta las poleas a la altura de los hombros.\n'
          '2. Párate en el centro y agarra los mangos.\n'
          '3. Jala los mangos hacia el centro cruzándolos ligeramente.\n'
          '4. Regresa controladamente.',
      tips: ['Mantén los codos ligeramente flexionados durante todo el movimiento.'],
    ),
    ExerciseModel(
      id: 'ex_pushup',
      name: 'Flexiones de Pecho',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.calisthenics,
      caloriesPerMinute: 7.0,
      isBodyweight: true,
      instructions:
          '1. Posición de plancha con manos a la anchura de hombros.\n'
          '2. Baja el pecho al suelo manteniendo el cuerpo recto.\n'
          '3. Empuja hasta la posición inicial.',
      tips: ['El cuerpo debe formar una línea recta de cabeza a talones.'],
    ),

    // ── BACK ─────────────────────────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_pullup',
      name: 'Dominadas',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.shoulders],
      equipment: Equipment.pullupBar,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.calisthenics,
      caloriesPerMinute: 10.0,
      isBodyweight: true,
      instructions:
          '1. Cuelga de la barra con agarre prono más ancho que hombros.\n'
          '2. Retrae los omóplatos y tira hasta que la barbilla supere la barra.\n'
          '3. Baja controladamente hasta extensión completa.',
      tips: [
        'Inicia el movimiento retrayendo los omóplatos, no con los brazos.',
        'Evita el balanceo del cuerpo.',
      ],
    ),
    ExerciseModel(
      id: 'ex_barbell_row',
      name: 'Remo con Barra',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.shoulders],
      equipment: Equipment.barbell,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.strength,
      caloriesPerMinute: 8.0,
      instructions:
          '1. Inclínate hacia adelante con la barra colgando.\n'
          '2. Mantén la espalda recta y paralela al suelo.\n'
          '3. Tira la barra hacia el ombligo.\n'
          '4. Baja controladamente.',
      tips: ['No uses impulso de caderas para levantar el peso.'],
    ),
    ExerciseModel(
      id: 'ex_lat_pulldown',
      name: 'Jalones en Polea',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps],
      equipment: Equipment.cables,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 7.0,
      instructions:
          '1. Siéntate en la máquina de jalones.\n'
          '2. Agarra la barra con agarre prono ancho.\n'
          '3. Jala la barra hacia el pecho superior.\n'
          '4. Regresa controladamente.',
      tips: ['Inclínate ligeramente hacia atrás para mejor contracción.'],
    ),
    ExerciseModel(
      id: 'ex_seated_row',
      name: 'Remo en Polea Baja',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.shoulders],
      equipment: Equipment.cables,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 7.0,
      instructions:
          '1. Siéntate frente a la polea baja con los pies en la plataforma.\n'
          '2. Agarra el mango y mantén la espalda erguida.\n'
          '3. Tira el mango hacia el abdomen apretando los omóplatos.\n'
          '4. Regresa controladamente.',
      tips: ['No redondees la espalda baja al regresar al punto de inicio.'],
    ),
    ExerciseModel(
      id: 'ex_deadlift',
      name: 'Peso Muerto',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes, MuscleGroup.quadriceps],
      equipment: Equipment.barbell,
      difficulty: ExerciseDifficulty.advanced,
      type: ExerciseType.strength,
      caloriesPerMinute: 11.0,
      instructions:
          '1. Párate frente a la barra con pies a la anchura de caderas.\n'
          '2. Agarra la barra con agarre mixto o doble prono.\n'
          '3. Mantén la espalda recta, pecho arriba y core activado.\n'
          '4. Levanta empujando los talones contra el suelo.\n'
          '5. Lleva la cadera hacia adelante al pasar las rodillas.\n'
          '6. Baja controladamente siguiendo el mismo patrón.',
      tips: [
        'La barra siempre debe estar pegada a las piernas.',
        'No redondees la espalda baja.',
        'Activa el core antes de comenzar el movimiento.',
      ],
    ),
    ExerciseModel(
      id: 'ex_face_pull',
      name: 'Face Pull',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.shoulders],
      equipment: Equipment.cables,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 6.0,
      instructions:
          '1. Ajusta la polea a la altura de la cara.\n'
          '2. Agarra la cuerda con ambas manos.\n'
          '3. Tira hacia la cara separando las manos al final.\n'
          '4. Regresa controladamente.',
      tips: ['Excelente para la salud de los hombros y postura.'],
    ),

    // ── SHOULDERS ────────────────────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_military_press',
      name: 'Press Militar',
      primaryMuscle: MuscleGroup.shoulders,
      secondaryMuscles: [MuscleGroup.triceps],
      equipment: Equipment.barbell,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.strength,
      caloriesPerMinute: 8.0,
      instructions:
          '1. De pie o sentado, agarra la barra a la altura de los hombros.\n'
          '2. Empuja la barra hacia arriba hasta la extensión completa.\n'
          '3. Baja controladamente a la posición inicial.',
      tips: [
        'No hiperextiendas la espalda baja.',
        'Activa el core durante todo el movimiento.',
      ],
    ),
    ExerciseModel(
      id: 'ex_lateral_raises',
      name: 'Elevaciones Laterales',
      primaryMuscle: MuscleGroup.shoulders,
      secondaryMuscles: [],
      equipment: Equipment.dumbbell,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 5.5,
      instructions:
          '1. De pie con mancuernas a los costados.\n'
          '2. Levanta los brazos lateralmente hasta la altura de los hombros.\n'
          '3. Baja controladamente.',
      tips: [
        'Inclina ligeramente las mancuernas hacia adelante.',
        'No uses impulso del cuerpo.',
      ],
    ),
    ExerciseModel(
      id: 'ex_front_raises',
      name: 'Elevaciones Frontales',
      primaryMuscle: MuscleGroup.shoulders,
      secondaryMuscles: [MuscleGroup.chest],
      equipment: Equipment.dumbbell,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 5.0,
      instructions:
          '1. De pie con mancuernas frente a los muslos.\n'
          '2. Levanta los brazos hacia adelante hasta la altura de los hombros.\n'
          '3. Baja controladamente.',
      tips: ['Mantén los codos ligeramente flexionados.'],
    ),
    ExerciseModel(
      id: 'ex_arnold_press',
      name: 'Press Arnold',
      primaryMuscle: MuscleGroup.shoulders,
      secondaryMuscles: [MuscleGroup.triceps],
      equipment: Equipment.dumbbell,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.strength,
      caloriesPerMinute: 7.0,
      instructions:
          '1. Sostén las mancuernas frente a ti con palmas hacia ti.\n'
          '2. Al presionar hacia arriba, gira las palmas hacia adelante.\n'
          '3. Al bajar, invierte la rotación.',
      tips: ['El rango de movimiento completo activa todos los haces del deltoides.'],
    ),

    // ── BICEPS ───────────────────────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_bicep_curl',
      name: 'Curl de Bíceps con Barra',
      primaryMuscle: MuscleGroup.biceps,
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.barbell,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 6.0,
      instructions:
          '1. De pie con agarre supino a la anchura de hombros.\n'
          '2. Flexiona los codos llevando la barra hacia los hombros.\n'
          '3. Baja controladamente.',
      tips: [
        'Mantén los codos pegados al cuerpo.',
        'No uses la espalda para levantar el peso.',
      ],
    ),
    ExerciseModel(
      id: 'ex_hammer_curl',
      name: 'Curl Martillo',
      primaryMuscle: MuscleGroup.biceps,
      secondaryMuscles: [MuscleGroup.forearms],
      equipment: Equipment.dumbbell,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 5.5,
      instructions:
          '1. De pie con mancuernas en agarre neutro (palmas hacia adentro).\n'
          '2. Flexiona los codos llevando las mancuernas hacia los hombros.\n'
          '3. Baja controladamente.',
      tips: ['También trabaja el braquial y braquiorradial.'],
    ),
    ExerciseModel(
      id: 'ex_concentration_curl',
      name: 'Curl de Concentración',
      primaryMuscle: MuscleGroup.biceps,
      secondaryMuscles: [],
      equipment: Equipment.dumbbell,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 5.0,
      instructions:
          '1. Siéntate en un banco con los pies separados.\n'
          '2. Apoya el codo en la cara interna del muslo.\n'
          '3. Curla la mancuerna hacia el hombro.\n'
          '4. Baja controladamente.',
      tips: ['Ideal para aislar y visualizar la contracción del bíceps.'],
    ),

    // ── TRICEPS ──────────────────────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_tricep_ext',
      name: 'Extensiones de Tríceps en Polea',
      primaryMuscle: MuscleGroup.triceps,
      secondaryMuscles: [],
      equipment: Equipment.cables,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 5.5,
      instructions:
          '1. Párate frente a la polea alta con la cuerda o barra.\n'
          '2. Mantén los codos pegados al cuerpo.\n'
          '3. Extiende los codos completamente.\n'
          '4. Regresa controladamente.',
      tips: ['Los codos no deben moverse durante el movimiento.'],
    ),
    ExerciseModel(
      id: 'ex_skull_crushers',
      name: 'Rompecráneos',
      primaryMuscle: MuscleGroup.triceps,
      secondaryMuscles: [],
      equipment: Equipment.barbell,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.strength,
      caloriesPerMinute: 6.0,
      instructions:
          '1. Acuéstate con barra EZ sobre el pecho.\n'
          '2. Extiende los brazos y baja la barra hacia la frente.\n'
          '3. Extiende los codos de vuelta a la posición inicial.',
      tips: ['Mantén los codos apuntando al techo durante todo el movimiento.'],
    ),
    ExerciseModel(
      id: 'ex_tricep_dips',
      name: 'Fondos en Banco',
      primaryMuscle: MuscleGroup.triceps,
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.chest],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.calisthenics,
      caloriesPerMinute: 7.0,
      isBodyweight: true,
      instructions:
          '1. Siéntate en el borde del banco con las manos al lado de las caderas.\n'
          '2. Deslízate hacia adelante y baja el cuerpo flexionando los codos.\n'
          '3. Empuja hasta la posición inicial.',
      tips: ['Mantén la espalda cerca del banco para enfatizar los tríceps.'],
    ),

    // ── CORE ─────────────────────────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_plank',
      name: 'Plancha',
      primaryMuscle: MuscleGroup.core,
      secondaryMuscles: [MuscleGroup.shoulders],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.calisthenics,
      caloriesPerMinute: 4.0,
      isBodyweight: true,
      instructions:
          '1. Apóyate en antebrazos y puntillas.\n'
          '2. Mantén el cuerpo recto de cabeza a talones.\n'
          '3. Activa el core y aguanta la posición.',
      tips: [
        'No dejes caer las caderas ni las levantes demasiado.',
        'Respira de forma constante.',
      ],
    ),
    ExerciseModel(
      id: 'ex_crunches',
      name: 'Crunches',
      primaryMuscle: MuscleGroup.core,
      secondaryMuscles: [],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.calisthenics,
      caloriesPerMinute: 5.0,
      isBodyweight: true,
      instructions:
          '1. Acuéstate boca arriba con rodillas flexionadas.\n'
          '2. Coloca las manos detrás de la cabeza.\n'
          '3. Levanta los hombros del suelo contrayendo el abdomen.\n'
          '4. Baja controladamente.',
      tips: ['No uses el cuello para levantarte; el trabajo debe venir del abdomen.'],
    ),
    ExerciseModel(
      id: 'ex_russian_twist',
      name: 'Russian Twist',
      primaryMuscle: MuscleGroup.core,
      secondaryMuscles: [],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.calisthenics,
      caloriesPerMinute: 5.5,
      isBodyweight: true,
      instructions:
          '1. Siéntate con rodillas flexionadas y pies elevados.\n'
          '2. Inclínate ligeramente hacia atrás.\n'
          '3. Gira el torso de lado a lado.',
      tips: ['Añade peso para aumentar la intensidad.'],
    ),
    ExerciseModel(
      id: 'ex_leg_raises',
      name: 'Elevación de Piernas',
      primaryMuscle: MuscleGroup.core,
      secondaryMuscles: [MuscleGroup.quadriceps],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.calisthenics,
      caloriesPerMinute: 5.0,
      isBodyweight: true,
      instructions:
          '1. Acuéstate boca arriba con piernas extendidas.\n'
          '2. Levanta las piernas hasta 90 grados.\n'
          '3. Baja controladamente sin que toquen el suelo.',
      tips: ['Mantén la zona lumbar pegada al suelo.'],
    ),
    ExerciseModel(
      id: 'ex_ab_wheel',
      name: 'Rueda Abdominal',
      primaryMuscle: MuscleGroup.core,
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.back],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.advanced,
      type: ExerciseType.calisthenics,
      caloriesPerMinute: 8.0,
      isBodyweight: true,
      instructions:
          '1. Arrodíllate y agarra la rueda.\n'
          '2. Rueda hacia adelante extendiendo el cuerpo.\n'
          '3. Vuelve a la posición inicial usando el core.',
      tips: ['Uno de los ejercicios más efectivos para el core.'],
    ),

    // ── LEGS / QUADS ─────────────────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_squat',
      name: 'Sentadilla con Barra',
      primaryMuscle: MuscleGroup.quadriceps,
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
      equipment: Equipment.barbell,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.strength,
      caloriesPerMinute: 10.0,
      instructions:
          '1. Coloca la barra en la parte alta de la espalda.\n'
          '2. Pies a la anchura de hombros con puntas ligeramente hacia afuera.\n'
          '3. Desciende como si fueras a sentarte manteniendo el pecho arriba.\n'
          '4. Sube empujando los talones contra el suelo.',
      tips: [
        'Las rodillas deben seguir la dirección de los pies.',
        'Profundidad mínima: muslos paralelos al suelo.',
      ],
    ),
    ExerciseModel(
      id: 'ex_leg_press',
      name: 'Prensa de Piernas',
      primaryMuscle: MuscleGroup.quadriceps,
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
      equipment: Equipment.machine,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 8.0,
      instructions:
          '1. Siéntate en la prensa con pies a la anchura de hombros.\n'
          '2. Libera los seguros y flexiona las rodillas hasta 90 grados.\n'
          '3. Empuja hasta casi la extensión completa.\n'
          '4. Repite.',
      tips: ['No bloquees completamente las rodillas al extender.'],
    ),
    ExerciseModel(
      id: 'ex_lunges',
      name: 'Zancadas con Mancuernas',
      primaryMuscle: MuscleGroup.quadriceps,
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
      equipment: Equipment.dumbbell,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 7.0,
      instructions:
          '1. De pie con mancuernas a los costados.\n'
          '2. Da un paso largo hacia adelante.\n'
          '3. Baja la rodilla trasera hacia el suelo.\n'
          '4. Empuja con el pie delantero para volver.',
      tips: ['Mantén el torso erguido durante todo el movimiento.'],
    ),
    ExerciseModel(
      id: 'ex_leg_extension',
      name: 'Extensión de Piernas',
      primaryMuscle: MuscleGroup.quadriceps,
      secondaryMuscles: [],
      equipment: Equipment.machine,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 6.0,
      instructions:
          '1. Siéntate en la máquina con las piernas bajo el rodillo.\n'
          '2. Extiende las piernas hasta la posición horizontal.\n'
          '3. Baja controladamente.',
      tips: ['Ideal para aislar el cuádriceps.'],
    ),

    // ── HAMSTRINGS / GLUTES ──────────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_rdl',
      name: 'Peso Muerto Rumano',
      primaryMuscle: MuscleGroup.hamstrings,
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back],
      equipment: Equipment.barbell,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.strength,
      caloriesPerMinute: 8.0,
      instructions:
          '1. De pie con la barra frente a los muslos.\n'
          '2. Con rodillas ligeramente flexionadas, baja la barra por las piernas.\n'
          '3. Empuja las caderas hacia atrás hasta sentir el estiramiento.\n'
          '4. Vuelve a la posición inicial empujando las caderas hacia adelante.',
      tips: ['La espalda siempre recta; el movimiento viene de las caderas.'],
    ),
    ExerciseModel(
      id: 'ex_hip_thrust',
      name: 'Hip Thrust',
      primaryMuscle: MuscleGroup.glutes,
      secondaryMuscles: [MuscleGroup.hamstrings],
      equipment: Equipment.barbell,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.strength,
      caloriesPerMinute: 7.5,
      instructions:
          '1. Apoya la parte alta de la espalda en un banco.\n'
          '2. Coloca la barra sobre las caderas.\n'
          '3. Empuja las caderas hacia arriba apretando los glúteos.\n'
          '4. Baja controladamente.',
      tips: ['Squeeze los glúteos en la posición superior.'],
    ),
    ExerciseModel(
      id: 'ex_leg_curl',
      name: 'Curl de Piernas',
      primaryMuscle: MuscleGroup.hamstrings,
      secondaryMuscles: [],
      equipment: Equipment.machine,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 6.0,
      instructions:
          '1. Acuéstate en la máquina con los tobillos bajo el rodillo.\n'
          '2. Flexiona las rodillas llevando los pies hacia los glúteos.\n'
          '3. Baja controladamente.',
      tips: ['Enfócate en la contracción isquiotibial.'],
    ),

    // ── CALVES ───────────────────────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_calf_raises',
      name: 'Elevaciones de Pantorrillas',
      primaryMuscle: MuscleGroup.calves,
      secondaryMuscles: [],
      equipment: Equipment.machine,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.strength,
      caloriesPerMinute: 4.5,
      instructions:
          '1. De pie en el borde de un escalón o plataforma.\n'
          '2. Elévate sobre las puntillas lo más alto posible.\n'
          '3. Baja hasta sentir el estiramiento en las pantorrillas.',
      tips: ['Mantén la posición superior 1 segundo para mayor activación.'],
    ),

    // ── CARDIO ───────────────────────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_burpees',
      name: 'Burpees',
      primaryMuscle: MuscleGroup.cardio,
      secondaryMuscles: [MuscleGroup.chest, MuscleGroup.quadriceps, MuscleGroup.core],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.plyometric,
      caloriesPerMinute: 12.0,
      isBodyweight: true,
      instructions:
          '1. De pie, baja al suelo en posición de flexión.\n'
          '2. Haz una flexión.\n'
          '3. Salta hacia adelante y luego arriba con los brazos extendidos.\n'
          '4. Repite.',
      tips: ['Mantén el ritmo constante para maximizar el gasto calórico.'],
    ),
    ExerciseModel(
      id: 'ex_box_jump',
      name: 'Box Jump',
      primaryMuscle: MuscleGroup.cardio,
      secondaryMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
      equipment: Equipment.box,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.plyometric,
      caloriesPerMinute: 11.0,
      isBodyweight: true,
      instructions:
          '1. Párate frente a una caja.\n'
          '2. Flexiona ligeramente las rodillas y salta sobre la caja.\n'
          '3. Aterriza con rodillas flexionadas.\n'
          '4. Baja caminando o saltando.',
      tips: ['Aterriza suavemente para proteger las rodillas.'],
    ),
    ExerciseModel(
      id: 'ex_jump_rope',
      name: 'Salto de Cuerda',
      primaryMuscle: MuscleGroup.cardio,
      secondaryMuscles: [MuscleGroup.calves, MuscleGroup.shoulders],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.cardio,
      caloriesPerMinute: 13.0,
      isBodyweight: true,
      instructions:
          '1. Sostén los mangos de la cuerda a la altura de las caderas.\n'
          '2. Salta con pies juntos haciendo girar la cuerda.\n'
          '3. Mantén el ritmo constante.',
      tips: ['Usa principalmente las muñecas para girar la cuerda.'],
    ),
    ExerciseModel(
      id: 'ex_running',
      name: 'Carrera en Cinta',
      primaryMuscle: MuscleGroup.cardio,
      secondaryMuscles: [MuscleGroup.quadriceps, MuscleGroup.hamstrings, MuscleGroup.calves],
      equipment: Equipment.machine,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.cardio,
      caloriesPerMinute: 10.0,
      isBodyweight: true,
      instructions:
          '1. Sube a la cinta y ajusta la velocidad.\n'
          '2. Mantén una postura erguida con mirada al frente.\n'
          '3. Corre el tiempo establecido.',
      tips: ['Varia la inclinación para aumentar la intensidad sin más velocidad.'],
    ),
    ExerciseModel(
      id: 'ex_mountain_climbers',
      name: 'Mountain Climbers',
      primaryMuscle: MuscleGroup.cardio,
      secondaryMuscles: [MuscleGroup.core, MuscleGroup.shoulders],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.cardio,
      caloriesPerMinute: 10.0,
      isBodyweight: true,
      instructions:
          '1. Posición de plancha alta.\n'
          '2. Alterna llevando las rodillas al pecho rápidamente.\n'
          '3. Mantén las caderas bajas.',
      tips: ['Mantén el core activado para mayor efectividad.'],
    ),

    // ── KETTLEBELL / FUNCTIONAL ──────────────────────────────────────────────
    ExerciseModel(
      id: 'ex_kb_swing',
      name: 'Kettlebell Swing',
      primaryMuscle: MuscleGroup.glutes,
      secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.core, MuscleGroup.back],
      equipment: Equipment.kettlebell,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.strength,
      caloriesPerMinute: 13.0,
      instructions:
          '1. De pie con la kettlebell entre los pies.\n'
          '2. Agarra con ambas manos e inclínate hacia adelante.\n'
          '3. Impulsa las caderas hacia adelante lanzando la kettlebell.\n'
          '4. Deja que baje entre las piernas y repite.',
      tips: ['El movimiento viene de las caderas, no de los brazos.'],
    ),
    ExerciseModel(
      id: 'ex_turkish_getup',
      name: 'Turkish Get-Up',
      primaryMuscle: MuscleGroup.fullBody,
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.core],
      equipment: Equipment.kettlebell,
      difficulty: ExerciseDifficulty.advanced,
      type: ExerciseType.strength,
      caloriesPerMinute: 9.0,
      instructions:
          '1. Acuéstate con la kettlebell en una mano, brazo extendido.\n'
          '2. Sigue los pasos: rodillo, pivot, plancha, arrodillarse, pararse.\n'
          '3. Invierte el proceso para volver al suelo.',
      tips: ['Practica primero sin peso para dominar la técnica.'],
    ),
    ExerciseModel(
      id: 'ex_battle_ropes',
      name: 'Battle Ropes',
      primaryMuscle: MuscleGroup.fullBody,
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.core],
      equipment: Equipment.noEquipment,
      difficulty: ExerciseDifficulty.intermediate,
      type: ExerciseType.cardio,
      caloriesPerMinute: 14.0,
      isBodyweight: true,
      instructions:
          '1. Agarra los extremos de las cuerdas con ambas manos.\n'
          '2. Crea ondas alternando los brazos arriba y abajo.\n'
          '3. Mantén el ritmo durante el tiempo establecido.',
      tips: ['Combina movimientos: ondas, circles, slam para variedad.'],
    ),
    ExerciseModel(
      id: 'ex_trx_row',
      name: 'Remo en TRX',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.core],
      equipment: Equipment.trx,
      difficulty: ExerciseDifficulty.beginner,
      type: ExerciseType.calisthenics,
      caloriesPerMinute: 7.0,
      isBodyweight: true,
      instructions:
          '1. Agarra las asas del TRX inclinado hacia atrás.\n'
          '2. Tira del cuerpo hacia los mangos retrayendo los omóplatos.\n'
          '3. Baja controladamente.',
      tips: ['Cuanto más inclinado estés, más difícil será el ejercicio.'],
    ),
  ];
}
