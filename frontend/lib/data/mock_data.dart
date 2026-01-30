import '../models/class_session_model.dart';

// URLs de imágenes públicas para fallback
const _imgBiblia = 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=800';
const _imgLibrosAntiguos = 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800';
const _imgSalomon = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800';
const _imgMarRojo = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800';
const _imgDavidGoliat = 'https://images.unsplash.com/photo-1569003339405-ea396a5a8a90?w=800';
const _imgJacob = 'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=800';
const _imgCorazon = 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800';
const _imgAdoracion = 'https://images.unsplash.com/photo-1445445290350-18a3b86e0b5a?w=800';
const _imgInvitacion = 'https://images.unsplash.com/photo-1473172707857-f9e276582ab6?w=800';
const _imgJob = 'https://images.unsplash.com/photo-1500099817043-86d46000d58f?w=800';
const _imgSalmos = 'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=800';
const _imgProverbios = 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800';
const _imgEclesiastes = 'https://images.unsplash.com/photo-1485841890310-6a055c88698a?w=800';
const _imgCantares = 'https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00?w=800';
const _imgParalelismo = 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=800';

final mockClassSession = ClassSession(
  id: 'session_1',
  title: 'Introducción',
  blocks: [
    ClassBlock(
      title: 'Introducción',
      slides: [
        Slide(
          id: 's1_1',
          type: SlideType.title,
          title: 'Introducción',
          content: 'Literatura sapiencial del Antiguo Testamento',
          imageUrl: _imgBiblia,
        ),
        Slide(
          id: 's1_2',
          type: SlideType.content,
          title: 'Un Legado Universal',
          content: 'La poesía del Antiguo Testamento es la contribución del pueblo hebreo a la literatura universal.',
          imageUrl: _imgLibrosAntiguos,
        ),
        Slide(
          id: 's1_3',
          type: SlideType.content,
          title: 'Literatura antigua',
          content: 'Como otros pueblos, la literatura más antigua de Israel fue poética. Pero... ¿cuál es el libro más antiguo de la Biblia?',
        ),
        Slide(
          id: 's1_3_activity',
          type: SlideType.activity,
          title: '¿Cuál es el libro más antiguo?',
          content: 'Cinco estudiantes pasarán al frente y elegirán una respuesta.',
          activity: ActivityData(
            question: '¿Cuál de estos libros se considera el más antiguo de la Biblia?',
            options: [
              'Génesis',
              'Job',
              'Salmos',
              'Proverbios',
              'Isaías',
            ],
            correctOptionIndex: 1,
            explanation: 'Respuesta correcta: JOB. Aunque Génesis narra los eventos más antiguos, el libro de Job fue probablemente escrito antes, posiblemente en la era patriarcal.',
          ),
        ),
        Slide(
          id: 's1_3b',
          type: SlideType.content,
          title: 'El Libro de Job',
          content: 'Job es considerado el libro más antiguo de la Biblia. Un libro poético que explora el sufrimiento humano y la soberanía de Dios.',
          biblicalReference: 'Job 1:1',
          imageUrl: _imgJob,
        ),
        Slide(
          id: 's1_4',
          type: SlideType.content,
          title: 'El canon incompleto',
          content: 'El Antiguo Testamento no contiene toda la literatura poética del pueblo israelita.',
        ),
        Slide(
          id: 's1_5',
          type: SlideType.content,
          title: 'Valor espiritual',
          content: 'En los libros sagrados se incluyeron poemas de valor espiritual. No todos están incluidos en el canon.',
        ),
        Slide(
          id: 's1_6',
          type: SlideType.content,
          title: 'Ejemplo: Salomón',
          content: 'Salomón compuso 3,000 proverbios y 1,005 cantares. Solo una parte está en el canon.',
          biblicalReference: '1 Reyes 4:32',
          imageUrl: _imgSalomon,
        ),
        Slide(
          id: 's1_6_reflexion',
          type: SlideType.reflection,
          title: 'Reflexión: ¿Por qué no están todos?',
          content: 'Si Salomón escribió 3,000 proverbios, ¿por qué solo tenemos unos 800 en el libro de Proverbios?',
        ),
        Slide(
          id: 's1_6_respuesta',
          type: SlideType.content,
          title: 'Razones teológicas',
          content: '1. El Espíritu Santo guió la selección de textos inspirados para edificación permanente. 2. Solo se preservaron los escritos con propósito espiritual eterno. 3. Algunos pudieron ser proverbios seculares o administrativos. 4. El canon incluye lo necesario para la fe y la vida piadosa.',
        ),
        Slide(
          id: 's2_1',
          type: SlideType.content,
          title: 'Origen antiguo',
          content: 'La poesía es una de las formas más antiguas de la literatura.',
        ),
        Slide(
          id: 's2_2',
          type: SlideType.content,
          title: 'Danza y ritmo',
          content: 'En algunas ocasiones se acompañaba de danza, dándole ritmo.',
          imageUrl: _imgAdoracion,
        ),
        Slide(
          id: 's2_3',
          type: SlideType.content,
          title: 'El detonante',
          content: 'Generalmente se manifestaba cuando Dios le daba al pueblo una victoria.',
        ),
        Slide(
          id: 's2_4',
          type: SlideType.title,
          title: 'Ejemplos bíblicos',
          content: 'Veamos tres ejemplos de poesía espontánea en la Escritura.',
        ),
        Slide(
          id: 's2_5',
          type: SlideType.content,
          title: 'Ejemplo 1: El Mar Rojo',
          content: 'Cuando el pueblo pasó el mar Rojo y fueron destruidos los egipcios...',
          biblicalReference: 'Éxodo 15:20-21',
          imageUrl: _imgMarRojo,
        ),
        Slide(
          id: 's2_6',
          type: SlideType.content,
          title: 'María y las mujeres',
          content: 'María y un grupo de mujeres tomaron panderos y danzaron.',
          biblicalReference: 'Éxodo 15:20-21',
        ),
        Slide(
          id: 's2_7',
          type: SlideType.content,
          title: 'Ejemplo 2: David y Goliat',
          content: 'Cuando David venció a Goliat...',
          biblicalReference: '1 Samuel 18:7',
          imageUrl: _imgDavidGoliat,
        ),
        Slide(
          id: 's2_8',
          type: SlideType.content,
          title: 'Celebración con canto',
          content: 'Saúl hirió a sus miles, y David a sus diez miles cantaban las mujeres que danzaban.',
          biblicalReference: '1 Samuel 18:7',
        ),
        Slide(
          id: 's2_9',
          type: SlideType.content,
          title: 'Ejemplo 3: Jacob',
          content: 'Jacob, antes de morir, reúne a sus doce hijos...',
          biblicalReference: 'Génesis 49',
          imageUrl: _imgJacob,
        ),
        Slide(
          id: 's2_10',
          type: SlideType.content,
          title: 'Bendición profética',
          content: 'Pronuncia sobre cada uno de ellos una bendición a la vez profética y poética.',
          biblicalReference: 'Génesis 49',
        ),
        Slide(
          id: 's3_1',
          type: SlideType.title,
          title: 'El corazón poético',
          content: 'Los cinco libros poéticos de la Palabra de Dios.',
          imageUrl: _imgCorazon,
        ),
        Slide(
          id: 's3_2',
          type: SlideType.content,
          title: 'Emociones Reales',
          content: 'En los cinco libros poéticos encontramos: quejas, enojos, gozo, llantos, dudas...',
        ),
        Slide(
          id: 's3_3',
          type: SlideType.content,
          title: 'Adoración genuina',
          content: '...así como alabanzas y adoración.',
          imageUrl: _imgAdoracion,
        ),
        Slide(
          id: 's3_4',
          type: SlideType.content,
          title: 'Más allá del canon',
          content: 'Aparte de los cinco libros poéticos que conocemos, también hubo poesía inspirada de y hacia Dios.',
        ),
        Slide(
          id: 's3_5',
          type: SlideType.content,
          title: 'Testigos Reales',
          content: 'Por hombres y mujeres que vieron y palparon la obra y el poder de Dios.',
        ),
        Slide(
          id: 's3_6',
          type: SlideType.reflection,
          title: 'Invitación',
          content: 'Quiero despertar en ustedes un interés muy especial por el estudio de estos libros. Sé que Dios les ministrará de una forma muy especial.',
          imageUrl: _imgInvitacion,
        ),
      ],
    ),
    ClassBlock(
      title: 'Libros poéticos',
      slides: [
        Slide(
          id: 's4_1',
          type: SlideType.title,
          title: 'Libros poéticos',
          content: 'Poesía y sabiduría hebrea: forma literaria, experiencias reales y voz inspirada por Dios.',
          imageUrl: 'assets/images/corazon_poetico.jpg',
        ),
        Slide(
          id: 's4_2',
          type: SlideType.content,
          title: '¿Qué son?',
          content: 'No son fantasía: es la forma poética en que se narran experiencias reales del pueblo de Dios.',
        ),
        Slide(
          id: 's4_2b',
          type: SlideType.content,
          title: 'Forma literaria, no ficción',
          content: 'El término poético no significa imaginario o irreal. Es solo la forma literaria en que estos libros fueron escritos.',
        ),
        Slide(
          id: 's4_2c',
          type: SlideType.content,
          title: 'Experiencias reales',
          content: 'Describen experiencias del pueblo de Dios en diversas circunstancias de la vida terrenal, permitidas por Dios y escritas por hombres inspirados por el Espíritu Santo.',
        ),
        Slide(
          id: 's4_2d',
          type: SlideType.content,
          title: 'Fe para cantar y celebrar',
          content: 'Su forma nos recuerda que la fe bíblica es apropiada para cantar y celebrar, no solo para recitar como un hecho histórico.',
        ),
        Slide(
          id: 's4_2e',
          type: SlideType.content,
          title: 'Emociones humanas completas',
          content: 'Aquí se pone delante de Dios la gama completa de las emociones humanas: quejas, llantos, dudas, enojos, como también alabanza y adoración.',
        ),
        Slide(
          id: 's4_3',
          type: SlideType.content,
          title: 'Libros incluidos',
          content: 'Job, Salmos, Proverbios, Eclesiastés, Cantares y Lamentaciones.',
        ),
        Slide(
          id: 's4_3b',
          type: SlideType.content,
          title: 'Géneros literarios',
          content: 'En ellos encontramos: poesía lírica, aforismos, epopeyas, poemas de amor, poemas espirituales, dramas, refranes, parábolas, acertijos y consejos.',
        ),
        Slide(
          id: 's4_3c',
          type: SlideType.content,
          title: 'Clasificación bíblica',
          content: 'La Biblia cristiana agrupa los libros en tres conjuntos: Libros históricos (incluyendo Pentateuco), Libros proféticos (mayores y menores), y Libros poéticos.',
        ),
        Slide(
          id: 's4_3d',
          type: SlideType.content,
          title: 'Los Escritos hebreos',
          content: 'En la Biblia hebrea, estos libros forman parte de Los Escritos: libros sagrados que no pertenecen ni a la Ley (Torá) ni a los Profetas.',
        ),
        Slide(
          id: 's4_3e',
          type: SlideType.content,
          title: 'Popularidad variada',
          content: 'Algunos son muy populares como Salmos y Job. Otros como Eclesiastés o Cantares son menos conocidos pero igualmente inspirados.',
        ),
        Slide(
          id: 's4_3f',
          type: SlideType.reflection,
          title: 'Palabra de Dios',
          content: 'Son libros sagrados y canónicos, auténticos, y en consecuencia, Palabra de Dios a los hombres.',
        ),
        Slide(
          id: 's4_3g_reflexion',
          type: SlideType.reflection,
          title: 'REFLEXIÓN: Emociones y Palabra de Dios',
          content: 'Si Dios nos habló a través de las emociones de los escritores (quejas, dudas, enojos, alegría)... ¿Esto se puede considerar Palabra de Dios?',
        ),
        Slide(
          id: 's4_3h_respuesta',
          type: SlideType.content,
          title: '¡SÍ! Inspiración divina',
          content: 'Dios usó las emociones REALES de personas REALES para comunicar verdades eternas. No dictó palabras como una máquina, sino que inspiró a hombres con sus propias experiencias. Eso hace la Biblia más auténtica y cercana a nosotros.',
          biblicalReference: '2 Timoteo 3:16',
        ),
      ],
    ),
    ClassBlock(
      title: 'Características peculiares',
      slides: [
        Slide(
          id: 's5_1',
          type: SlideType.title,
          title: 'Características peculiares',
          content: 'La naturaleza única de los libros poéticos.',
          imageUrl: 'assets/images/libros_antiguos.jpg',
        ),
        Slide(
          id: 's5_2',
          type: SlideType.content,
          title: 'Palabra humana inspirada',
          content: 'En estos libros no encontramos leyes ni profetas. Es el hombre piadoso quien reza en los Salmos, los enamorados en Cantares, y los sabios en los libros sapienciales.',
        ),
        Slide(
          id: 's5_3',
          type: SlideType.content,
          title: 'Paradoja de la inspiración',
          content: 'Parece escucharse solo la voz de los autores, pero sus palabras fueron escritas bajo el carisma de la inspiración divina. Son Palabra de Dios modalizada como oración, amor o sabiduría.',
        ),
        Slide(
          id: 's5_4',
          type: SlideType.title,
          title: 'PARALELISMO POÉTICO',
          content: 'Un tercio del AT es poesía. A diferencia del español, la poesía hebrea no tiene rima ni metro, sino que repite ideas en renglones consecutivos.',
        ),
        Slide(
          id: 's5_5',
          type: SlideType.content,
          title: '¿Qué es el paralelismo?',
          content: 'El segundo verso corresponde, contradice o completa el primero. Ejemplo: A- Engrandeced a Jehová conmigo / B- Y exaltemos a una su nombre.',
        ),
        Slide(
          id: 's5_6',
          type: SlideType.title,
          title: 'PARALELISMO SINONIMO',
          content: 'El segundo verso repite con diferentes palabras el pensamiento del primero. Son palabras de igual significado.',
        ),
        Slide(
          id: 's5_7',
          type: SlideType.content,
          title: 'Ejemplos sinónimos',
          content: 'Salmo 6:1 - Yahvé, no me corrijas en tu cólera, en tu furor no me castigues. Salmo 2:4 - El que mora en los cielos se reirá; el Señor se burlará de ellos.',
          biblicalReference: 'Salmo 6:1, 2:4',
        ),
        Slide(
          id: 's5_8',
          type: SlideType.content,
          title: 'Más ejemplos sinónimos',
          content: 'Génesis 4:23 - Ada y Zila, oíd mi voz; mujeres de Lamec, escuchad mi dicho. Salmo 103:10 - No ha hecho conforme a nuestras iniquidades, ni pagado conforme a nuestros pecados.',
          biblicalReference: 'Génesis 4:23, Salmo 103:10',
        ),
        Slide(
          id: 's5_9',
          type: SlideType.title,
          title: 'PARALELISMO ANTITETICO',
          content: 'Contrapone dos frases de significado contrario. A veces repite en forma negativa el pensamiento del primero.',
        ),
        Slide(
          id: 's5_10',
          type: SlideType.content,
          title: 'Ejemplos antitéticos',
          content: 'Salmo 34:10 - Los leoncillos necesitan y tienen hambre; pero los que buscan a Jehová no tendrán falta. Proverbios 10:1 - El hijo sabio alegra al padre, mas el necio es tristeza de su madre.',
          biblicalReference: 'Salmo 34:10, Proverbios 10:1',
        ),
        Slide(
          id: 's5_11',
          type: SlideType.content,
          title: 'Más ejemplos antitéticos',
          content: 'Proverbios 20:29 - La gloria de los jóvenes es su fuerza, la hermosura de los ancianos es su vejez. Salmo 1:6 - Jehová conoce el camino de los justos; la senda de los malos perecerá.',
          biblicalReference: 'Proverbios 20:29, Salmo 1:6',
        ),
        Slide(
          id: 's5_12',
          type: SlideType.title,
          title: 'PARALELISMO SINTÉTICO',
          content: 'También llamado progresivo. El segundo verso completa el pensamiento del primero, extendiéndolo o explicándolo.',
        ),
        Slide(
          id: 's5_13',
          type: SlideType.content,
          title: 'Ejemplos sintéticos',
          content: 'Proverbios 26:4 - Nunca respondas al necio según su necedad, para que no seas como él. Salmo 115:9 - Oh Israel, confía en Jehová; él es tu ayuda y tu escudo.',
          biblicalReference: 'Proverbios 26:4, Salmo 115:9',
        ),
        Slide(
          id: 's5_14',
          type: SlideType.content,
          title: 'Más ejemplos sintéticos',
          content: 'Salmo 123:1 - A ti alcé mis ojos, a ti que habitas en los cielos. Job 11:18 - Tendrás confianza porque hay esperanza; mirarás alrededor y dormirás seguro.',
          biblicalReference: 'Salmo 123:1, Job 11:18',
        ),
        Slide(
          id: 's5_15',
          type: SlideType.title,
          title: 'Clasificación de la poesía',
          content: 'Los libros poéticos son: Líricos, Épicos y Dramáticos. La poesía religiosa se divide en cinco clases.',
        ),
        Slide(
          id: 's5_16',
          type: SlideType.content,
          title: 'Cinco clases de poesía religiosa',
          content: 'Lírica (sentimientos), Épica o Epopeya (hazañas), Gnómica o Proverbial (sabiduría), Dramática (diálogos), y Elegíaca (lamento).',
        ),
        Slide(
          id: 's5_17',
          type: SlideType.content,
          title: 'Poesía secular en la Biblia',
          content: 'Canción del Pozo (Números 21:17-18), Matrimonio de Rebeca (Génesis 24:60), Endecha de David (2 Samuel 1:17-27), Canción de la Victoria (Jueces 5), La Viña (Isaías 5:1-7).',
        ),
        Slide(
          id: 's5_18',
          type: SlideType.content,
          title: 'Paronomasia (juego de palabras)',
          content: 'Paronomasia: palabras muy parecidas en escritura pero de significado distinto. Isaías 5:7 - Dios esperaba mishpat (justicia) y halló mishpah (derramamiento de sangre), esperaba tsedhaqa (rectitud) y halló tseaqa (un grito de terror).',
          biblicalReference: 'Isaías 5:7',
        ),
        Slide(
          id: 's5_19',
          type: SlideType.content,
          title: 'Poesía vigorosa',
          content: 'La poesía hebrea es vigorosa porque describe la función de los sentidos: mi garganta se ha secado, han desfallecido mis ojos, se envejecieron mis huesos.',
        ),
        Slide(
          id: 's5_20',
          type: SlideType.reflection,
          title: 'Interpretación correcta',
          content: 'Los poemas deben interpretarse según las normas de la poesía hebrea, no como prosa literal. Hay que tomar en cuenta las figuras y metáforas.',
        ),
        Slide(
          id: 's5_21',
          type: SlideType.content,
          title: 'Ejemplo de figura',
          content: 'Jueces 5:20 - Desde los cielos pelearon las estrellas; desde sus órbitas pelearon contra Sísara. No se entiende literalmente sino como figura poética.',
          biblicalReference: 'Jueces 5:20',
        ),
      ],
    ),
    ClassBlock(
      title: 'Clases de poesía hebrea',
      slides: [
        Slide(
          id: 's6_1',
          type: SlideType.title,
          title: 'CLASES DE POESÍA HEBREA',
          content: 'Descubre los cinco tipos de poesía que dan vida a la literatura bíblica. ¿Cuál te impacta más?',
        ),
        Slide(
          id: 's6_2',
          type: SlideType.title,
          title: '1. POESÍA LÍRICA',
          content: 'El canto del alma. Expresa sentimientos profundos, ideales para ser cantados con la lira.',
        ),
        Slide(
          id: 's6_3',
          type: SlideType.content,
          title: 'Música para Dios',
          content: '¿Sabías que el culto de Israel era poesía cantada? Himnos de alabanza, lamentos desgarradores y dulces poemas de amor.',
        ),
        Slide(
          id: 's6_4',
          type: SlideType.content,
          title: 'Historia hecha canción',
          content: 'Desde el Éxodo, Israel cantó su historia. La poesía lírica inundó cada periodo de su vida como nación.',
        ),
        Slide(
          id: 's6_5',
          type: SlideType.content,
          title: 'Victorias inolvidables',
          content: 'Imagina el estruendo del mar: Moisés canta tras cruzar el Mar Rojo (Éx 15). O la fuerza de Débora celebrando la victoria (Jueces 5).',
          biblicalReference: 'Éxodo 15, Jueces 5',
          imageUrl: 'assets/images/mar_rojo.jpg',
        ),
        Slide(
          id: 's6_6',
          type: SlideType.content,
          title: 'El corazón al desnudo',
          content: '¿Sientes culpa? Lee los Salmos 32 y 51, el clamor de un arrepentido implorando misericordia.',
          biblicalReference: 'Salmos 32 y 51',
        ),
        Slide(
          id: 's6_7',
          type: SlideType.content,
          title: 'De la angustia a la fe',
          content: 'Angustia mortal en Isaías 38, pero también fe inquebrantable en Habacuc 3 y gratitud desbordante en el Salmo 40.',
          biblicalReference: 'Isaías 38, Habacuc 3, Salmo 40',
        ),
        Slide(
          id: 's6_8',
          type: SlideType.title,
          title: '2. POESÍA ÉPICA',
          content: 'Relatos de gloria. La narración de sucesos legendarios que definen a una nación.',
        ),
        Slide(
          id: 's6_9',
          type: SlideType.content,
          title: 'Héroes y batallas',
          content: 'No solo se canta, se cuenta. La épica se centra en héroes, intervenciones divinas y grandes batallas físicas.',
        ),
        Slide(
          id: 's6_10',
          type: SlideType.content,
          title: 'Lírica vs Épica',
          content: 'La Lírica se canta y siente (emoción). La Épica se recita y narra (acción). Dos formas de vivir la fe.',
        ),
        Slide(
          id: 's6_11',
          type: SlideType.title,
          title: '3. POESÍA GNÓMICA',
          content: 'Sabiduría en cápsulas. Pensamientos breves, agudos y memorables.',
        ),
        Slide(
          id: 's6_12',
          type: SlideType.content,
          title: '¿Dónde la encontramos?',
          content: 'Brilla en Proverbios y Eclesiastés. Pequeñas joyas de sabiduría esparcidas por todo el Antiguo Testamento.',
        ),
        Slide(
          id: 's6_13',
          type: SlideType.title,
          title: '4. POESÍA DRAMÁTICA',
          content: 'Teatro de la vida. Poesía que conmueve y presenta diálogos intensos.',
        ),
        Slide(
          id: 's6_14',
          type: SlideType.content,
          title: 'El drama de Job',
          content: 'Job no es teatro, es la epopeya de la vida interior. Una lucha dramática con el dolor y la duda.',
          biblicalReference: 'Libro de Job',
        ),
        Slide(
          id: 's6_15',
          type: SlideType.content,
          title: 'Drama de amor',
          content: 'Cantares dialoga sobre el amor apasionado. Un drama poético que celebra la unión.',
          biblicalReference: 'Cantar de los Cantares',
        ),
        Slide(
          id: 's6_16',
          type: SlideType.title,
          title: '5. POESÍA ELEGÍACA',
          content: 'El canto del dolor. Cuando la tristeza se vuelve poesía.',
        ),
        Slide(
          id: 's6_17',
          type: SlideType.content,
          title: 'Lamentaciones',
          content: 'Jeremías llora sobre las ruinas. Un ejemplo supremo de elegía. También David llorando a Saúl y Jonatán.',
          biblicalReference: 'Lamentaciones, 2 Samuel 1:19',
        ),
      ],
    ),
    ClassBlock(
      title: 'Los libros sapienciales',
      slides: [
        Slide(
          id: 's7_1',
          type: SlideType.title,
          title: 'LOS LIBROS SAPIENCIALES',
          content: 'Libros que contienen sabiduría: refranes populares, reflexión creativa y composición poética.',
        ),
        Slide(
          id: 's7_2',
          type: SlideType.content,
          title: 'Formas de sabiduría',
          content: 'Algunos eran refranes tradicionales o populares, otros llevan el sello de la reflexión y composición creativa. Se entretejen con la poesía.',
        ),
        Slide(
          id: 's7_3',
          type: SlideType.content,
          title: 'Diversas expresiones',
          content: 'Poemas breves en Proverbios, largas composiciones en Job y Eclesiastés. También máximas, refranes, acertijos y parábolas.',
          biblicalReference: 'Jueces 9:8-15, 14:14, 1 Samuel 24:13, 2 Samuel 12:1-6',
        ),
        Slide(
          id: 's7_4',
          type: SlideType.content,
          title: 'Sabiduría israelita única',
          content: 'A diferencia de otros pueblos orientales, en Israel se combina la revelación divina con el conocimiento adquirido por experiencia.',
        ),
        Slide(
          id: 's7_5',
          type: SlideType.content,
          title: 'Don de Dios',
          content: 'Es una cualidad que se cultiva mediante instrucción, pero también es un don de Dios y fruto inspirado por su Espíritu.',
          biblicalReference: 'Job 11:6, Proverbios 2:6, Job 32:8',
        ),
        Slide(
          id: 's7_6',
          type: SlideType.content,
          title: 'Temática central',
          content: 'Desde consejos prácticos para una vida provechosa, hasta reflexiones sobre la relación entre la sabiduría y obedecer la ley divina.',
        ),
        Slide(
          id: 's7_7',
          type: SlideType.content,
          title: 'Job y Eclesiastés',
          content: 'A Job le atormenta el sufrimiento de los justos. Eclesiastés es una triste reflexión sobre el significado de la vida a las puertas de la muerte.',
        ),
        Slide(
          id: 's7_8',
          type: SlideType.content,
          title: 'Personificación de la sabiduría',
          content: 'Llama la atención cómo la sabiduría es personificada en varios pasajes.',
          biblicalReference: 'Job 28:12-27, Proverbios 1:20-33, 8:1-2, 9:1-6',
        ),
        Slide(
          id: 's7_9',
          type: SlideType.reflection,
          title: 'Enseñanza para hoy',
          content: 'El contenido de la poesía nos deja gran enseñanza, inspiración y motivación para expresarla a Dios, que es la fuente de la sabiduría.',
        ),
        Slide(
          id: 's7_10',
          type: SlideType.content,
          title: 'Preparación para Cristo',
          content: 'Como todos los libros del AT, estos preparaban la Revelación plena de Dios en Jesucristo, consignada por escrito en el Nuevo Testamento.',
        ),
      ],
    ),
    ClassBlock(
      title: 'Actividades dinámicas',
      slides: [
        Slide(
          id: 's8_1',
          type: SlideType.title,
          title: 'Actividades interactivas',
          content: 'Participa con tu celular: identifica, clasifica y reflexiona sobre la poesía.',
        ),
        Slide(
          id: 's8_2',
          type: SlideType.activity,
          title: 'Actividad 1: Identifica el paralelismo',
          content: 'Los cielos cuentan la gloria de Dios, y el firmamento anuncia la obra de sus manos.',
          biblicalReference: 'Salmo 19:1',
          activity: ActivityData(
            question: '¿Qué tipo de paralelismo se observa?',
            options: [
              'Paralelismo sinónimo',
              'Paralelismo antitético',
              'Paralelismo sintético',
              'Paralelismo climático',
            ],
            correctOptionIndex: 0,
            explanation: 'Respuesta correcta: PARALELISMO SINÓNIMO. Ambas líneas expresan la misma idea con palabras diferentes.',
          ),
        ),
        Slide(
          id: 's8_3',
          type: SlideType.activity,
          title: 'Actividad 2: Identifica el paralelismo',
          content: 'El hijo sabio alegra al padre, pero el hijo necio es tristeza de su madre.',
          biblicalReference: 'Proverbios 10:1',
          activity: ActivityData(
            question: '¿Qué tipo de paralelismo se observa en este versículo?',
            options: [
              'Paralelismo sinónimo',
              'Paralelismo antitético',
              'Paralelismo sintético',
              'Paralelismo emblemático',
            ],
            correctOptionIndex: 1,
            explanation: 'Respuesta correcta: PARALELISMO ANTITÉTICO. Las dos líneas contrastan ideas opuestas: sabio vs necio, alegría vs tristeza.',
          ),
        ),
        Slide(
          id: 's8_4',
          type: SlideType.activity,
          title: 'Actividad 3: Identifica el libro',
          content: 'Vanidad de vanidades, todo es vanidad.',
          biblicalReference: 'Eclesiastés 1:2',
          activity: ActivityData(
            question: '¿A qué libro poético pertenece esta famosa frase?',
            options: [
              'Job',
              'Salmos',
              'Proverbios',
              'Eclesiastés',
              'Cantares',
            ],
            correctOptionIndex: 3,
            explanation: 'Respuesta correcta: ECLESIASTÉS. Esta frase es el tema central del libro, escrito por Salomón reflexionando sobre el sentido de la vida.',
          ),
        ),
        Slide(
          id: 's8_5',
          type: SlideType.activity,
          title: 'Actividad 4: Completa el versículo',
          content: 'El principio de la sabiduría es el temor de...',
          biblicalReference: 'Proverbios 9:10',
          activity: ActivityData(
            question: 'Completa: El principio de la sabiduría es el temor de...',
            options: [
              'los hombres',
              'la muerte',
              'Jehová',
              'el pecado',
              'lo desconocido',
            ],
            correctOptionIndex: 2,
            explanation: 'Respuesta correcta: JEHOVÁ. Este es uno de los versículos más importantes de la literatura sapiencial.',
          ),
        ),
        Slide(
          id: 's8_6',
          type: SlideType.activity,
          title: 'Actividad 5: Tipo de literatura',
          content: 'Béseme él de los besos de su boca; porque mejores son tus amores que el vino.',
          biblicalReference: 'Cantares 1:2',
          activity: ActivityData(
            question: '¿Qué tipo de poesía representa este versículo?',
            options: [
              'Poesía de lamento',
              'Poesía de sabiduría',
              'Poesía de amor',
              'Poesía profética',
              'Poesía de alabanza',
            ],
            correctOptionIndex: 2,
            explanation: 'Respuesta correcta: POESÍA DE AMOR. Cantares es un poema de amor que celebra la relación entre el esposo y la esposa.',
          ),
        ),
        Slide(
          id: 's8_7',
          type: SlideType.content,
          title: 'Lamentaciones',
          content: 'Jeremías llora sobre las ruinas. Un ejemplo supremo de elegía. También David llorando a Saúl y Jonatán.',
          biblicalReference: 'Lamentaciones, 2 Samuel 1:19',
        ),
        Slide(
          id: 's8_8',
          type: SlideType.activity,
          title: 'Actividad 7: El libro de Job',
          content: '¿Recibiremos de Dios el bien, y el mal no lo recibiremos?',
          biblicalReference: 'Job 2:10',
          activity: ActivityData(
            question: '¿Qué característica define mejor al libro de Job?',
            type: ActivityType.multipleChoice,
            options: [
              'Drama sobre el sufrimiento y la soberanía de Dios',
              'Una comedia romántica',
              'Un libro de leyes',
              'Una colección de himnos'
            ],
            correctOptionIndex: 0,
            explanation: 'Correcto: Job es un drama profundo que explora el sufrimiento humano bajo la soberanía divina.',
          ),
        ),
        Slide(
          id: 's8_9',
          type: SlideType.activity,
          title: 'Actividad 8: Ordena el Versículo',
          content: 'Ordena las palabras para formar este versículo clave de la literatura sapiencial.',
          biblicalReference: 'Proverbios 1:7',
          activity: ActivityData(
            question: 'Construye el versículo correcto:',
            type: ActivityType.wordPuzzle,
            options: [
              'sabiduría', 'El', 'de', 'temor', 'Jehová', 'es', 'la', 'principio', 'el', 'de'
            ],
            correctWordOrder: [
              'El', 'principio', 'de', 'la', 'sabiduría', 'es', 'el', 'temor', 'de', 'Jehová'
            ],
            correctOptionIndex: 0, 
            explanation: '¡Correcto! "El principio de la sabiduría es el temor de Jehová". Este es el lema de toda la literatura sapiencial.',
          ),
        ),
        Slide(
          id: 's8_10',
          type: SlideType.activity,
          title: 'Actividad 9: Job y la Esperanza',
          content: 'Ordena la famosa declaración de fe de Job en medio de su sufrimiento.',
          biblicalReference: 'Job 19:25',
          activity: ActivityData(
            question: 'Reconstruye la declaración:',
            type: ActivityType.wordPuzzle,
            options: [
              'vive', 'Yo', 'mi', 'Redentor', 'sé', 'que', 'levantará', 'polvo', 'el', 'sobre', 'Y', 'fin', 'al', 'se' 
            ],
            correctWordOrder: [
              'Yo', 'sé', 'que', 'mi', 'Redentor', 'vive', 'Y', 'al', 'fin', 'se', 'levantará', 'sobre', 'el', 'polvo'
            ],
            correctOptionIndex: 0,
            explanation: '¡Muy bien! "Yo sé que mi Redentor vive...". Una de las expresiones de fe más potentes del Antiguo Testamento.',
          ),
        ),
        Slide(
          id: 's8_11',
          type: SlideType.activity,
          title: 'Actividad 10: El Pastor Divino',
          content: 'Ordena el inicio del Salmo más conocido de la Biblia.',
          biblicalReference: 'Salmo 23:1',
          activity: ActivityData(
            question: 'Completa el versículo:',
            type: ActivityType.wordPuzzle,
            options: [
              'pastor', 'Jehová', 'es', 'mi', 'nada', 'faltará', 'me'
            ],
            correctWordOrder: [
              'Jehová', 'es', 'mi', 'pastor', 'nada', 'me', 'faltará'
            ],
            correctOptionIndex: 0,
            explanation: '¡Excelente! "Jehová es mi pastor; nada me faltará". La máxima expresión de confianza en la provisión de Dios.',
          ),
        ),
        Slide(
          id: 's8_12',
          type: SlideType.activity,
          title: 'Actividad 11: Los Tiempos de Dios',
          content: 'Ordena este versículo sobre la soberanía de Dios en el tiempo.',
          biblicalReference: 'Eclesiastés 3:1',
          activity: ActivityData(
            question: 'Ordena el texto:',
            type: ActivityType.wordPuzzle,
            options: [
              'Todo', 'tiempo', 'su', 'tiene', 'y', 'todo', 'lo', 'que', 'quiere', 'se', 'debajo', 'cielo', 'del', 'tiene', 'hora', 'su'
            ],
            correctWordOrder: [
              'Todo', 'tiene', 'su', 'tiempo', 'y', 'todo', 'lo', 'que', 'se', 'quiere', 'debajo', 'del', 'cielo', 'tiene', 'su', 'hora'
            ],
            correctOptionIndex: 0,
            explanation: '¡Correcto! "Todo tiene su tiempo...". Nos enseña a discernir los momentos oportunos en la vida bajo el sol.',
          ),
        ),
      ],
    ),
    ClassBlock(
      title: 'Actividades',
      slides: [
        Slide(
          id: 's9_1',
          type: SlideType.title,
          title: 'Actividades',
          content: 'Evalúa y refuerza lo aprendido sobre poesía y sabiduría hebreas.',
          imageUrl: 'assets/images/adoracion.jpg',
        ),
      ],
    ),
  ],
);
