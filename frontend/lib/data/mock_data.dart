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

final unit1Session = ClassSession(
  id: 'session_1',
  title: 'Unidad 1: Literatura Sapiencial',
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

              'Salmos',

              'Job',

              'Isaías',

              'Proverbios',

            ],

            correctOptionIndex: 2,
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

              'Paralelismo antitético',

              'Paralelismo sinónimo',

              'Paralelismo climático',

              'Paralelismo sintético',

            ],

            correctOptionIndex: 1,
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

              'Paralelismo sintético',

              'Paralelismo emblemático',

              'Paralelismo antitético',

              'Paralelismo sinónimo',

            ],

            correctOptionIndex: 2,
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

              'Eclesiastés',

              'Salmos',

              'Cantares',

              'Proverbios',

            ],

            correctOptionIndex: 1,
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

              'Jehová',

              'los hombres',

              'la muerte',

              'lo desconocido',

              'el pecado',

            ],

            correctOptionIndex: 0,
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

              'Poesía de sabiduría',

              'Poesía de lamento',

              'Poesía profética',

              'Poesía de amor',

              'Poesía de alabanza',

            ],

            correctOptionIndex: 3,
            explanation: 'Respuesta correcta: POESÍA DE AMOR. Cantares es un poema de amor que celebra la relación entre el esposo y la esposa.',
          ),
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

              'Una comedia romántica',

              'Drama sobre el sufrimiento y la soberanía de Dios',

              'Una colección de himnos',

              'Un libro de leyes',

            ],

            correctOptionIndex: 1,
            explanation: 'Correcto: Job es un drama profundo que explora el sufrimiento humano bajo la soberanía divina.',
          ),
        ),
        Slide(
          id: 's8_9',
          type: SlideType.activity,
          title: 'Actividad 8: Proverbios 1:7',
          content: 'Selecciona el versículo correcto de la literatura sapiencial.',
          biblicalReference: 'Proverbios 1:7',
          activity: ActivityData(
            question: '¿Cuál es el principio de la sabiduría según Proverbios 1:7?',
            type: ActivityType.multipleChoice,
            options: [

              'El principio de la sabiduría es el conocimiento',

              'El principio de la sabiduría es el temor de Jehová',

              'El principio de la sabiduría es la fe',

              'El principio de la sabiduría es la obediencia',

            ],

            correctOptionIndex: 1,
            explanation: '¡Correcto! "El principio de la sabiduría es el temor de Jehová" - Este es el versículo fundamental de toda la literatura sapiencial.',
          ),
        ),
        Slide(
          id: 's8_10',
          type: SlideType.activity,
          title: 'Actividad 9: Job y la Esperanza',
          content: 'La famosa declaración de fe de Job en medio de su sufrimiento.',
          biblicalReference: 'Job 19:25',
          activity: ActivityData(
            question: '¿Qué declaró Job en medio de su sufrimiento? (Job 19:25)',
            type: ActivityType.multipleChoice,
            options: [

              'Yo sé que Dios es bueno',

              'Yo sé que mi Redentor vive',

              'Yo sé que todo pasará',

              'Yo sé que seré restaurado',

            ],

            correctOptionIndex: 1,
            explanation: '¡Excelente! Job declaró: "Yo sé que mi Redentor vive, Y al fin se levantará sobre el polvo" - Una poderosa declaración de fe en medio del sufrimiento.',
          ),
        ),
        Slide(
          id: 's8_11',
          type: SlideType.activity,
          title: 'Actividad 10: El Pastor Divino',
          content: 'El Salmo más conocido de la Biblia.',
          biblicalReference: 'Salmo 23:1',
          activity: ActivityData(
            question: '¿Cómo comienza el Salmo 23?',
            type: ActivityType.multipleChoice,
            options: [

              'Jehová es mi luz y mi salvación',

              'Jehová es mi pastor; nada me faltará',

              'Jehová es mi refugio y mi castillo',

              'Jehová es mi fortaleza y mi escudo',

            ],

            correctOptionIndex: 1,
            explanation: '¡Excelente! "Jehová es mi pastor; nada me faltará" (Salmo 23:1). La máxima expresión de confianza en la provisión de Dios.',
          ),
        ),
        Slide(
          id: 's8_12',
          type: SlideType.activity,
          title: 'Actividad 11: Los Tiempos de Dios',
          content: 'La soberanía de Dios en el tiempo según Eclesiastés.',
          biblicalReference: 'Eclesiastés 3:1',
          activity: ActivityData(
            question: '¿Qué nos enseña Eclesiastés 3:1 sobre el tiempo?',
            type: ActivityType.multipleChoice,
            options: [
              'Todo tiene su tiempo, y todo lo que se quiere debajo del cielo tiene su hora',
              'El tiempo es oro y no debemos perderlo',
              'Debemos aprovechar cada momento de la vida',
              'El tiempo pasará pero la Palabra permanece',
            ],
            correctOptionIndex: 0,
            explanation: '¡Correcto! "Todo tiene su tiempo, y todo lo que se quiere debajo del cielo tiene su hora". Nos enseña a discernir los momentos oportunos en la vida bajo el sol.',
          ),
        ),
        Slide(
          id: 's8_13_puzzle',
          type: SlideType.activity,
          title: 'Actividad 12: Ordena el Versículo',
          content: 'Ordena las palabras correctamente para formar el versículo.',
          biblicalReference: 'Salmo 119:105',
          activity: ActivityData(
            question: 'Ordena el siguiente versículo:',
            type: ActivityType.wordPuzzle,
            options: [
              'camino',
              'lámpara',
              'mi',
              'es',
              'tu',
              'a',
              'palabra',
              'pies',
              'y',
              'mis',
              'lumbrera',
              'a',
            ],
            correctOptionIndex: 0,
            correctWordOrder: [
              'lámpara',
              'es',
              'a',
              'mis',
              'pies',
              'tu',
              'palabra',
              'y',
              'lumbrera',
              'a',
              'mi',
              'camino',
            ],
            explanation: '¡Muy bien! "Lámpara es a mis pies tu palabra, y lumbrera a mi camino." (Salmo 119:105)',
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
        Slide(
          id: 's9_2',
          type: SlideType.activity,
          title: 'Quiz - Pregunta 1',
          content: 'Verdadero o Falso',
          activity: ActivityData(
            question: 'El libro de Job es considerado el más antiguo de la Biblia.',
            type: ActivityType.trueFalse,
            options: [
              'Verdadero',
              'Falso',
            ],
            correctOptionIndex: 0,
            explanation: '¡Correcto! Job es considerado el libro más antiguo de la Biblia, posiblemente escrito en la era patriarcal.',
          ),
        ),
        Slide(
          id: 's9_3',
          type: SlideType.activity,
          title: 'Quiz - Pregunta 2',
          content: 'Selecciona la opción correcta',
          activity: ActivityData(
            question: '¿Cuáles son los cinco libros poéticos del Antiguo Testamento?',
            type: ActivityType.multipleChoice,
            options: [
              'Job, Salmos, Proverbios, Eclesiastés, Cantares',
              'Génesis, Éxodo, Levítico, Números, Deuteronomio',
              'Mateo, Marcos, Lucas, Juan, Hechos',
              'Isaías, Jeremías, Ezequiel, Daniel, Oseas',
            ],
            correctOptionIndex: 0,
            explanation: '¡Excelente! Los cinco libros poéticos son: Job, Salmos, Proverbios, Eclesiastés y Cantares.',
          ),
        ),
        Slide(
          id: 's9_4',
          type: SlideType.activity,
          title: 'Quiz - Pregunta 3',
          content: 'Verdadero o Falso',
          activity: ActivityData(
            question: 'El paralelismo es la característica principal de la poesía hebrea, no la rima ni el metro.',
            type: ActivityType.trueFalse,
            options: [
              'Verdadero',
              'Falso',
            ],
            correctOptionIndex: 0,
            explanation: '¡Muy bien! A diferencia de otras lenguas, la poesía hebrea usa paralelismo (repetición de ideas) en lugar de rima o metro.',
          ),
        ),
        Slide(
          id: 's9_5',
          type: SlideType.activity,
          title: 'Quiz - Pregunta 4',
          content: 'Selecciona la opción correcta',
          activity: ActivityData(
            question: '¿Cuál es el versículo clave de la literatura sapiencial?',
            type: ActivityType.multipleChoice,
            options: [
              'El principio de la sabiduría es el temor de Jehová',
              'Amarás a tu prójimo como a ti mismo',
              'Yo soy el camino, la verdad y la vida',
              'Pedid y se os dará',
            ],
            correctOptionIndex: 0,
            explanation: '¡Perfecto! "El principio de la sabiduría es el temor de Jehová" (Proverbios 1:7) es el lema central de la literatura sapiencial.',
          ),
        ),
        // SOPA DE LETRAS INTERACTIVA (Deshabilitada por ahora)
        /*
        Slide(
          id: 's9_6',
          type: SlideType.activity,
          title: 'Sopa de Letras: Sabiduría',
          content: 'Encuentra las 15 palabras clave sobre la literatura sapiencial en el tiempo límite.',
          activity: ActivityData(
            question: 'Busca: PARALELISMO, SINONIMICO, ANTITETICO, SINTETICO, CLIMATICO, JOB, SALMOS, PROVERBIOS, ECLESIASTES, CANTARES, SABIDURIA, TEMOR, JUSTICIA, ENSEÑANZA, VERDAD.',
            type: ActivityType.wordSearch,
            options: [
              'PARALELISMO',
              'SINONIMICO',
              'ANTITETICO',
              'SINTETICO',
              'CLIMATICO',
              'JOB',
              'SALMOS',
              'PROVERBIOS',
              'ECLESIASTES',
              'CANTARES',
              'SABIDURIA',
              'TEMOR',
              'JUSTICIA',
              'ENSEÑANZA',
              'VERDAD'
            ],
            correctOptionIndex: 0,
            explanation: '¡Excelente! Encontraste todas las palabras clave de la literatura sapiencial.',
            percentageValue: 25, // Vale más puntos
          ),
        ),
        */
      ],
    ),
  ],
);


final unit2Session = ClassSession(
  id: 'session_2',
  title: 'Unidad 2: El Libro de Job',
  blocks: [
    ClassBlock(
      title: 'Introducción General',
      slides: [
        Slide(
          id: 'u2_b1_s1',
          type: SlideType.title,
          title: '¿Quién fue Job?',
          content: 'Su nombre significa "arrepentimiento" o "perseguido". Es recordado universalmente como el gran ejemplo de paciencia en medio del dolor.',
          imageUrl: 'https://images.unsplash.com/photo-1500099817043-86d46000d58f?w=800',
        ),
        Slide(
          id: 'u2_b1_s2',
          type: SlideType.content,
          title: 'Género Literario',
          content: 'Pertenece a la literatura sapiencial al tratar preguntas universales. Es un poema dramático enmarcado en un relato épico, escrito mayormente en verso.',
        ),
        Slide(
          id: 'u2_b1_s3',
          type: SlideType.content,
          title: 'Un Relato Verídico',
          content: 'No es una alegoría. La Biblia confirma su existencia real (Ez 14:14, Stg 5:11). Era un hombre rico y seminómada que conocía a Dios como "Shaddai".',
          biblicalReference: 'Ezequiel 14:14',
        ),
        Slide(
          id: 'u2_b1_s4',
          type: SlideType.content,
          title: 'Estructura del Libro',
          content: '1. Prólogo (Prosa)\n2. Diálogos con amigos (Verso)\n3. Discursos de Eliú\n4. Dios habla desde la tempestad\n5. Epílogo (Prosa)',
        ),
        Slide(
          id: 'u2_b1_s5',
          type: SlideType.content,
          title: 'Fecha y Contexto',
          content: 'La historia de Job ocurrió en la era patriarcal (aprox. 2000-1800 a.C.), antes de la ley mosaica. Job era sacerdote de su propia familia y su riqueza se medía en ganado, características típicas de la época de Abraham.',
        ),
        Slide(
          id: 'u2_b1_s5e',
          type: SlideType.content,
          title: '🎬 Mapa Histórico: La Tierra de Uz',
          content: '{{MAP_JOB_HISTORICO}}', // Widget animado estilo documental
        ),
        Slide(
          id: 'u2_b1_s5f',
          type: SlideType.content,
          title: '🎬 Línea de Tiempo Animada',
          content: '{{TIMELINE_JOB}}', // Widget de línea de tiempo animada
        ),
        Slide(
          id: 'u2_b1_s6',
          type: SlideType.content,
          title: 'Autoría y Redacción',
          content: 'Autor desconocido. Aunque la tradición menciona a Moisés, el estilo sapiencial sugiere a un sabio de la época de Salomón, quien dio forma poética a una historia real antigua.',
        ),
        Slide(
          id: 'u2_b1_s7',
          type: SlideType.content,
          title: 'El Gran Tema: Teodicea',
          content: 'Trata el problema del sufrimiento de los justos. Refuta la teoría de la retribución (sufrimiento = castigo) y muestra que los caminos de Dios son soberanos y misteriosos.',
        ),
        Slide(
          id: 'u2_b1_s8',
          type: SlideType.content,
          title: 'Los Protagonistas',
          content: 'Job (Integridad probada), Satanás (Acusador cínico), Los Amigos (Defensores de la tradición y el dogma), y Dios (Soberanía absoluta y sabiduría infinita).',
        ),
      ],
    ),
    ClassBlock(
      title: 'Prólogo',
      slides: [
        Slide(
          id: 'u2_b2_s1',
          type: SlideType.title,
          title: 'El Prólogo (Job 1-2)',
          content: 'Job es un "hombre cabal, recto, que temía a Dios y se apartaba del mal". Piadoso, rico y cabeza de una numerosa familia de cierto prestigio.',
          biblicalReference: 'Job 1:1',
        ),
        Slide(
          id: 'u2_b2_s2',
          type: SlideType.content,
          title: 'La Escena Celestial',
          content: 'Un día "en que los Hijos de Dios venían a presentarse ante Yahvé", Dios pregunta a Satán qué opina de la rectitud de Job. Satán afirma que Job maldecirá a Dios si perdiese su riqueza.',
          biblicalReference: 'Job 1:6',
        ),
        Slide(
          id: 'u2_b2_s3',
          type: SlideType.content,
          title: 'El Desafío de Satanás',
          content: '¿Teme Job a Dios de balde? El adversario cuestiona la piedad de Job y sugiere que si le quita todo lo que tiene, Job negará a Dios.',
          biblicalReference: 'Job 1:9',
        ),
        Slide(
          id: 'u2_b2_s4',
          type: SlideType.content,
          title: 'Las Pruebas de Job',
          content: 'Dios permite a Satanás probar la fe de Job, privándole de sus bienes, su familia y por último, su salud. Satán procede a despojar a Job de sus posesiones e incluso de sus hijos, y más tarde llena su cuerpo de llagas dolorosas en grado extremo.',
        ),
        Slide(
          id: 'u2_b2_s5',
          type: SlideType.content,
          title: 'La Fidelidad de Job',
          content: 'Con todo, Job se niega a maldecir a Dios. "No pecó Job con sus labios". Tres de sus amigos llegan para confortarle, pero quedan aturdidos "y ninguno de ellos dijo una palabra, porque veían que el dolor era muy grande".',
          biblicalReference: 'Job 2:10, 13',
        ),
        Slide(
          id: 'u2_b2_s6',
          type: SlideType.title,
          title: 'Grandes Versículos de Job',
          content: 'En este libro hay dichos que han llegado a ser parte de la expresión de la piedad cristiana.',
        ),
        Slide(
          id: 'u2_b2_s7',
          type: SlideType.content,
          title: 'Dichos de Confianza (Parte 1)',
          content: '"Desnudo salí del vientre de mi madre, y desnudo volveré allá"\n\n"Jehová dio, y Jehová quitó, sea el nombre de Jehová bendito"',
          biblicalReference: 'Job 1:21',
        ),
        Slide(
          id: 'u2_b2_s8',
          type: SlideType.content,
          title: 'Dichos de Confianza (Parte 2)',
          content: '"¿Recibiremos de Dios el bien, y el mal no lo recibiremos?" (Respuesta a su esposa que le instaba maldecir a Dios y morir)\n\n"He aquí, aunque él me matare, en él esperaré"',
          biblicalReference: 'Job 2:10, 13:15',
        ),
        Slide(
          id: 'u2_b2_s9',
          type: SlideType.content,
          title: 'La Gran Declaración de Fe',
          content: '"Yo sé que mi Redentor vive, y que él será mi abogado aquí en la tierra, y aunque la piel se me caiga a pedazos, yo en persona, veré a Dios. Con mis propios ojos he de verlo, yo mismo y no un extraño"',
          biblicalReference: 'Job 19:25-27',
        ),
        Slide(
          id: 'u2_b2_s10',
          type: SlideType.title,
          title: 'Preguntas que Hallan Respuesta en Cristo',
          content: 'Job plantea preguntas profundas que solo encuentran respuesta plena en Jesucristo.',
        ),
        Slide(
          id: 'u2_b2_s11',
          type: SlideType.content,
          title: '¿Cómo se Justificará el Hombre?',
          content: '"¿Y cómo se justificará el hombre con Dios?"',
          biblicalReference: 'Job 9:2',
        ),
        Slide(
          id: 'u2_b2_s12',
          type: SlideType.content,
          title: 'Respuesta en Cristo',
          content: '"Justificados, pues, por la fe, tenemos paz para con Dios por medio de nuestro Señor Jesucristo"',
          biblicalReference: 'Romanos 5:1',
        ),
        Slide(
          id: 'u2_b2_s13',
          type: SlideType.content,
          title: '¿Quién Hará Limpio lo Inmundo?',
          content: '"¿Quién hará limpio a lo inmundo?"',
          biblicalReference: 'Job 14:4',
        ),
        Slide(
          id: 'u2_b2_s14',
          type: SlideType.content,
          title: 'Respuesta en Cristo',
          content: '"La sangre de Jesucristo su Hijo nos limpia de todo pecado"',
          biblicalReference: '1 Juan 1:7',
        ),
        Slide(
          id: 'u2_b2_s15',
          type: SlideType.content,
          title: '¿Hay un Mediador?',
          content: '"¡Oh, quién hará que Dios me escuche! No hay entre nosotros árbitro que ponga su mano sobre nosotros dos"',
          biblicalReference: 'Job 31:35, 9:33',
        ),
        Slide(
          id: 'u2_b2_s16',
          type: SlideType.content,
          title: 'Respuesta en Cristo',
          content: '"Hay un solo Dios, y un solo mediador entre Dios y los hombres, Jesucristo hombre"\n\n"Abogado tenemos para con el Padre, a Jesucristo el justo"',
          biblicalReference: '1 Timoteo 2:5, 1 Juan 2:1',
        ),
        Slide(
          id: 'u2_b2_s17',
          type: SlideType.content,
          title: '¿Volverá a Vivir el Hombre?',
          content: '"Si el hombre muriere, ¿volverá a vivir?"',
          biblicalReference: 'Job 14:14',
        ),
        Slide(
          id: 'u2_b2_s18',
          type: SlideType.content,
          title: 'Respuesta en Cristo',
          content: '"Yo soy la resurrección y la vida; el que cree en mí, aunque esté muerto, vivirá"',
          biblicalReference: 'Juan 11:25',
        ),
      ],
    ),
    ClassBlock(
      title: 'Job y sus amigos',
      slides: [
        Slide(
          id: 'u2_b3_s1',
          type: SlideType.title,
          title: 'Job y Sus Amigos',
          content: 'Tras el primer lamento de Job (capítulo 3), consta de tres ciclos de discursos. La mayor parte del libro está dedicada a estos diálogos.',
        ),
        Slide(
          id: 'u2_b3_s2',
          type: SlideType.content,
          title: 'El Silencio Inicial',
          content: 'Cuando sus tres amigos lo visitan, quedan tan impresionados de su condición, que se sientan en silencio durante siete días antes de empezar sus discursos.',
        ),
        Slide(
          id: 'u2_b3_s3',
          type: SlideType.content,
          title: 'Los Tres Amigos',
          content: 'Elifaz temanita, Bildad suhita y Sofar naamatita parten de la misma premisa: que los grandes sufrimientos se deben a gran pecado. Tratan de llevar a Job al convencimiento de su culpa.',
        ),
        Slide(
          id: 'u2_b3_s4',
          type: SlideType.content,
          title: 'El Dilema de Job',
          content: '¿Es Dios enemigo de Job? ¿Por qué no hay tribunales de justicia donde Job puede presentar su causa delante del Altísimo? ¿Por qué no hay árbitro que pueda poner su mano sobre las dos partes?',
          biblicalReference: 'Job 23:3-4, 9:33',
        ),
        Slide(
          id: 'u2_b3_s5',
          type: SlideType.content,
          title: 'La Gran Pregunta',
          content: 'Los cuatro buscan contestar la pregunta: ¿Por qué sufre el justo? A pesar de los grandes vituperios contra su vida, Job sostiene que es inocente.',
        ),
        Slide(
          id: 'u2_b3_s6',
          type: SlideType.content,
          title: 'Un Nuevo Concepto',
          content: 'Otro concepto se introduce en la discusión: que los sufrimientos de Job no son por castigo, sino que constituyen un medio para probar su carácter.',
          biblicalReference: 'Job 5:17',
        ),
        Slide(
          id: 'u2_b3_s7',
          type: SlideType.content,
          title: 'La Fe Inquebrantable de Job',
          content: 'El mismo Job no abandona la convicción de que Dios es su amigo. De alguna manera Él intervendrá para vindicar a su siervo.',
          biblicalReference: 'Job 19:25',
        ),
        Slide(
          id: 'u2_b3_s8',
          type: SlideType.title,
          title: 'Satanás en el Libro de Job',
          content: 'Un espíritu escéptico respecto del hombre, deseoso de encontrarle defectos y de poder acusarle ante Dios.',
        ),
        Slide(
          id: 'u2_b3_s9',
          type: SlideType.content,
          title: 'El Carácter de Satanás',
          content: 'No puede creer que los hombres sirven a Dios desinteresadamente, sino con motivos tan egoístas como los suyos. Es un ser malvado, cínico, de ironía fría, ansioso de desatar sobre los hombres toda suerte de males.',
        ),
        Slide(
          id: 'u2_b3_s10',
          type: SlideType.title,
          title: 'Perfil de los Amigos',
          content: 'Cada uno con su personalidad distintiva, pero todos defendiendo la tesis tradicional: el padecimiento es retribución divina.',
        ),
        Slide(
          id: 'u2_b3_s11',
          type: SlideType.content,
          title: 'Elifaz el Temanita',
          content: 'Sabio venerable y devoto, con entendimiento penetrante acompañado de compasión tierna; pero capaz, a la vez, de ser severo. Argumenta basándose en la experiencia de sus largos años y los hechos.',
        ),
        Slide(
          id: 'u2_b3_s12',
          type: SlideType.content,
          title: 'Bildad el Suhita',
          content: 'Una persona sentenciosa, más erudita, conocedora de las tradiciones. Su discurso es más cortés pero su lenguaje más áspero que el de Elifaz.',
        ),
        Slide(
          id: 'u2_b3_s13',
          type: SlideType.content,
          title: 'Sofar el Naamatita',
          content: 'Más impetuoso, dejándose llevar por los arrebatos juveniles. Es un moralista dogmático e intolerante de las ideas de Job.',
        ),
        Slide(
          id: 'u2_b3_s14',
          type: SlideType.content,
          title: 'La Reacción de Job',
          content: 'Job, que proclama su inocencia con resolución, primero se irrita y acto seguido monta en cólera contra sus amigos por sus opiniones quizá injustificadas y frívolas.',
        ),
        Slide(
          id: 'u2_b3_s15',
          type: SlideType.content,
          title: 'El Clamor de Job',
          content: '"¡Oh! ¿Quién hará que se me escuche? Esta es mi última palabra: ¡respóndeme, Šadday!"',
          biblicalReference: 'Job 31:35',
        ),
        Slide(
          id: 'u2_b3_s16',
          type: SlideType.content,
          title: 'El Carácter de Job',
          content: 'Job tiene el carácter más elevado que el de los demás. Su personalidad demuestra pasión combinada con fe inquebrantable en Dios, paciencia inagotable, tenacidad en protestar lo que le parece ser la injusticia.',
        ),
        Slide(
          id: 'u2_b3_s17',
          type: SlideType.content,
          title: 'Capítulos 28-31',
          content: 'El capítulo 28 es un bello elogio a la sabiduría. Del 29 al 31 es un resumen hecho por Job de todo el debate anterior. En la confusión moral del debate, se oyen alternadamente gritos de protesta y palabras de sumisión.',
        ),
      ],
    ),
    ClassBlock(
      title: 'Discurso de Eliú',
      slides: [
        Slide(
          id: 'u2_b4_s1',
          type: SlideType.title,
          title: 'Eliú Entra en Escena',
          content: 'El último discurso es dado por Eliú. Un joven arameo que procura ser más positivo y original que los tres amigos.',
          biblicalReference: 'Job 32-37',
        ),
        Slide(
          id: 'u2_b4_s2',
          type: SlideType.content,
          title: 'Lo Distintivo de Eliú',
          content: 'Se distingue de los primeros tres en su énfasis: el sufrimiento puede ser el misericordioso castigo de Dios, a fin de iluminarle el alma y originar una relación más perfecta con Dios.',
          biblicalReference: 'Job 33:30, 36:7-10',
        ),
        Slide(
          id: 'u2_b4_s3',
          type: SlideType.content,
          title: 'Pero Comparte la Premisa',
          content: 'Sin embargo, como los otros consejeros, Eliú suponía que Job había pecado y por consiguiente merecía su sufrimiento.',
        ),
        Slide(
          id: 'u2_b4_s4',
          type: SlideType.content,
          title: 'El Consejo de Eliú',
          content: 'Cuando Eliú habla acerca de poner su fe en Dios, en lugar de pedir explicaciones, le sugiere que cambie de actitud y se humille.',
        ),
        Slide(
          id: 'u2_b4_s5',
          type: SlideType.content,
          title: 'La Ira de Eliú',
          content: 'Su ira va dirigida contra Job "porque pretendía tener razón frente a Dios" y contra sus tres amigos "porque no habían hallado nada que replicar y de esa forma habían dejado mal a Dios".',
          biblicalReference: 'Job 32:2-3',
        ),
        Slide(
          id: 'u2_b4_s6',
          type: SlideType.content,
          title: 'La Acusación de Eliú',
          content: 'Eliú sostiene que Job "a su pecado le añade rebeldía" por cuestionar el juicio de Dios.',
          biblicalReference: 'Job 34:37',
        ),
        Slide(
          id: 'u2_b4_s7',
          type: SlideType.content,
          title: 'La Grandeza de Dios',
          content: '"¡Es Šadday! No podemos alcanzarle. Grande en fuerza y equidad"',
          biblicalReference: 'Job 37:23',
        ),
        Slide(
          id: 'u2_b4_s8',
          type: SlideType.content,
          title: 'El Carácter de Eliú',
          content: 'Su alto concepto de sí mismo se destaca más que su capacidad intelectual. Desautoriza a Job y a sus amigos justificando a Dios con una elocuencia difusa.',
        ),
        Slide(
          id: 'u2_b4_s9',
          type: SlideType.content,
          title: 'Transición: Dios Responde',
          content: 'Después de dar cada uno su discurso, Dios responde desde un torbellino. Posiblemente, el propósito de Dios era enfrentar a Job con sus sentimientos de autoestima y autojustificación.',
        ),
      ],
    ),
    ClassBlock(
      title: 'Dios habla',
      slides: [
        Slide(
          id: 'u2_b5_s1',
          type: SlideType.title,
          title: 'Dios Responde desde el Torbellino',
          content: '"¿Dónde estabas tú cuando yo fundaba la tierra?"',
          biblicalReference: 'Job 38:4',
        ),
        Slide(
          id: 'u2_b5_s2',
          type: SlideType.content,
          title: 'Soberanía Divina',
          content: 'Dios no explica su justicia, sino que revela su poder y sabiduría infinita. Las preguntas de Dios (Job 38-41) confirman el conocimiento de Job sobre la bondad y grandeza de Dios.',
          biblicalReference: 'Job 38-41',
        ),
        Slide(
          id: 'u2_b5_s3',
          type: SlideType.content,
          title: 'Dios a Su Lado',
          content: 'El que creó y sostiene al mundo con todas sus maravillas, no ha perdido de vista su sufrimiento. Job halló a Dios a su lado, no tan cercano como en sus días de prosperidad, pero más íntimamente conocido.',
        ),
        Slide(
          id: 'u2_b5_s4',
          type: SlideType.content,
          title: 'La Refutación de Dios',
          content: 'Con preguntas irrelevantes, Dios refuta a Job y presenta su respuesta más directa a una pregunta que éste formulara en el pasado.',
          biblicalReference: 'Job 40:8',
        ),
        Slide(
          id: 'u2_b5_s5',
          type: SlideType.content,
          title: 'La Pregunta de Job',
          content: '"¿Qué es Šadday para que le sirvamos, qué podemos ganar con aplacarle?"',
          biblicalReference: 'Job 21:15',
        ),
        Slide(
          id: 'u2_b5_s6',
          type: SlideType.content,
          title: 'El Arrepentimiento de Job',
          content: 'Reconociendo al fin que sus palabras han estado guiadas por la ignorancia y que lo máximo que puede hacer es acercarse a Dios a través de una visión de éste, Job se arrepiente.',
          biblicalReference: 'Job 42:1-6',
        ),
      ],
    ),
    ClassBlock(
      title: 'Epílogo',
      slides: [
        Slide(
          id: 'u2_b6_s1',
          type: SlideType.title,
          title: 'El Epílogo',
          content: 'Última sección del libro (Job 38:1 al 42:6). Dios refuta los argumentos de los tres amigos de Job.',
          biblicalReference: 'Job 42',
        ),
        Slide(
          id: 'u2_b6_s2',
          type: SlideType.content,
          title: 'Dios Vindica a Job',
          content: '"No habéis hablado con verdad de mí, como mi siervo Job." Eliú no aparece en la reprensión de Dios.',
          biblicalReference: 'Job 42:7',
        ),
        Slide(
          id: 'u2_b6_s3',
          type: SlideType.content,
          title: 'La Intervención Divina',
          content: 'En el epílogo llega la intervención divina y la humillación de Job, recuperando así su prosperidad con creces, mostrándose la superabundante bondad de Dios.',
        ),
        Slide(
          id: 'u2_b6_s4',
          type: SlideType.content,
          title: 'Dios desde la Tempestad',
          content: 'Dios habla desde el seno de la tempestad. Parece ignorar por completo el deseo que tiene Job de una explicación. En cambio, humilla a Job y le desafía para que explique cómo fue creado el universo.',
        ),
        Slide(
          id: 'u2_b6_s5',
          type: SlideType.content,
          title: 'La Restauración',
          content: 'Otorga a Job el doble de las riquezas y posesiones que tuviera en otro tiempo, le bendice con siete hijos y tres hermosas hijas y prolonga sus días.',
          biblicalReference: 'Job 42:10-17',
        ),
        Slide(
          id: 'u2_b6_s6',
          type: SlideType.content,
          title: 'Estilo Literario',
          content: 'El epílogo, al igual que el prólogo, está compuesto en prosa, y allí es donde se refleja con mayor claridad el probable origen popular de los discursos.',
        ),
        Slide(
          id: 'u2_b6_s7',
          type: SlideType.content,
          title: 'Paz y Alegría',
          content: 'Esta es la parte final de todo el poema y es aquí cuando la paz y la alegría regresan al alma de Job al oír la voz de Jehová.',
        ),
        Slide(
          id: 'u2_b6_s8',
          type: SlideType.title,
          title: 'El Clímax del Poema',
          content: '"De oídas te había oído; mas ahora mis ojos te ven."',
          biblicalReference: 'Job 42:5',
        ),
        Slide(
          id: 'u2_b6_s9',
          type: SlideType.content,
          title: 'Palabras de Satisfacción',
          content: 'Cuando Job dio esta expresión, su enfermedad estaba al extremo; sin embargo, eso no le preocupó ante el gozo de haber obtenido su victoria, pasando por encima de toda circunstancia adversa.',
        ),
        Slide(
          id: 'u2_b6_s10',
          type: SlideType.content,
          title: 'La Victoria de Job',
          content: 'Job llegó al tribunal divino; y así nos enseña que no importa lo que estemos pasando, Dios nos sacará adelante.',
        ),
        Slide(
          id: 'u2_b6_s11',
          type: SlideType.content,
          title: 'Más Allá del Sufrimiento',
          content: 'Este libro va más allá del problema del sufrimiento; llega profundamente al problema de las relaciones personales del hombre con Dios, que al final no es algo que tenga una explicación sino una experiencia.',
        ),
      ],
    ),
    ClassBlock(
      title: 'Bosquejo',
      slides: [
        Slide(
          id: 'u2_b7_s1',
          type: SlideType.title,
          title: 'Bosquejo del Libro de Job',
          content: 'Estructura literaria y teológica completa del libro.',
        ),
        Slide(
          id: 'u2_b7_s2',
          type: SlideType.content,
          title: 'I. El Prólogo (1-2)',
          content: 'El desafío de Satanás y la prueba de Job.\n\nA. La piedad y prosperidad de Job (1:1-5)\nB. Job puesto a prueba pero permanece fiel (1:6-2:13)',
        ),
        Slide(
          id: 'u2_b7_s3',
          type: SlideType.content,
          title: 'II. Primer Ciclo del Debate (3-14)',
          content: 'A. Lamento de Job (3)\nB. Primer discurso de Elifaz (4-5): Exhorta a Job a someterse y arrepentirse\nC. Job protesta y se defiende (6-7): Solo el afligido conoce su desdicha',
        ),
        Slide(
          id: 'u2_b7_s4',
          type: SlideType.content,
          title: 'II. Primer Ciclo (Continuación)',
          content: 'D. Primer discurso de Bildad (8): Las quejas de Job ponían en duda la justicia divina\nE. Job contesta a Bildad (9-10): Ningún mortal puede discutir su inocencia ante el Todopoderoso',
        ),
        Slide(
          id: 'u2_b7_s5',
          type: SlideType.content,
          title: 'II. Primer Ciclo (Final)',
          content: 'F. Primer discurso de Sofar (11): Acusa de maldad a Job. Dios tiene razón y tú no la tienes\nG. Job contesta a Sofar (12-14): Señala que los malos prosperan y defiende su integridad',
        ),
        Slide(
          id: 'u2_b7_s6',
          type: SlideType.content,
          title: 'III. Segundo Ciclo del Debate (15-21)',
          content: 'A. Segundo discurso de Elifaz (15): Acusa a Job de presunción\nB. Job contesta (16-17): Apelará a Dios para ser vindicado\nC. Segundo discurso de Bildad (18): Job sufre el castigo merecido',
        ),
        Slide(
          id: 'u2_b7_s7',
          type: SlideType.content,
          title: 'III. Segundo Ciclo (Final)',
          content: 'D. Job expresa confianza en Dios (19)\nE. Segundo discurso de Sofar (20): Acusa a Job de rechazar a Dios\nF. Job contesta a Sofar (21): El impío no padece en esta vida',
        ),
        Slide(
          id: 'u2_b7_s8',
          type: SlideType.content,
          title: 'IV. Tercer Ciclo del Debate (22-31)',
          content: 'A. Tercer discurso de Elifaz (22): Imputa faltas graves a Job\nB. Job afirma que el mal triunfa (23-24)\nC. Tercer discurso de Bildad (25): El hombre no puede ser justificado ante Dios',
        ),
        Slide(
          id: 'u2_b7_s9',
          type: SlideType.content,
          title: 'IV. Tercer Ciclo (Final)',
          content: 'D. Job responde a Bildad (26-27): Dios es soberano y juzgará al impío\nE. El elogio de la sabiduría divina (28)\nF. Conclusión: quejas y apología de Job (29-31)',
        ),
        Slide(
          id: 'u2_b7_s10',
          type: SlideType.content,
          title: 'V. Discursos de Eliú (32-37)',
          content: 'A. Eliú interviene en el debate (32:1-5)\nB. Primer discurso (32:6-33:33): El fracaso de los tres sabios\nC. Segundo discurso (34): Eliú contesta las acusaciones de Job',
        ),
        Slide(
          id: 'u2_b7_s11',
          type: SlideType.content,
          title: 'V. Discursos de Eliú (Final)',
          content: 'D. Tercer discurso (35): Eliú anima a Job a esperar pacientemente\nE. Cuarto discurso (36-37): Eliú exalta la grandeza de Dios',
        ),
        Slide(
          id: 'u2_b7_s12',
          type: SlideType.content,
          title: 'VI. Jehová Confunde a Job (38:1-42:6)',
          content: 'A. Primer discurso de Dios (38:1-40:2): Empleando preguntas, despliega su sabiduría infinita\nB. Job se humilla ante Dios (40:3-5)',
        ),
        Slide(
          id: 'u2_b7_s13',
          type: SlideType.content,
          title: 'VI. Jehová Confunde a Job (Final)',
          content: 'C. Segundo discurso de Dios (40:6-41:34): Manifestaciones del poder divino sobre la creación\nD. Arrepentimiento y confesión de Job (42:1-6)',
        ),
        Slide(
          id: 'u2_b7_s14',
          type: SlideType.content,
          title: 'VII. Epílogo (42:7-17)',
          content: 'A. Jehová vindica a Job (42:7-9)\nB. Jehová restaura la situación original de Job (42:10-17)',
        ),
      ],
    ),
    ClassBlock(
      title: 'Actividades y Dinámicas',
      slides: [
        Slide(
          id: 'u2_act_intro',
          type: SlideType.title,
          title: 'Actividades Interactivas',
          content: 'Participa con tu celular: demuestra tu comprensión del libro de Job.',
        ),
        Slide(
          id: 'u2_act_1',
          type: SlideType.activity,
          title: 'Actividad 1: El Carácter de Job',
          content: '¿Cómo describe la Biblia a Job al inicio del libro?',
          biblicalReference: 'Job 1:1',
          activity: ActivityData(
            question: '¿Cuál era la descripción de Job según Job 1:1?',
            type: ActivityType.multipleChoice,
            options: [
              'Un hombre sabio y elocuente',
              'Un hombre cabal, recto, que temía a Dios y se apartaba del mal',
              'Un hombre pobre pero justo',
              'Un profeta del Señor',
              'Un sacerdote del templo',
            ],
            correctOptionIndex: 1,
            explanation: '¡Correcto! Job era "un hombre cabal, recto, que temía a Dios y se apartaba del mal" - La descripción más completa de integridad en el AT.',
          ),
        ),
        Slide(
          id: 'u2_act_2',
          type: SlideType.activity,
          title: 'Actividad 2: El Desafío de Satanás',
          content: '¿Qué pregunta cínica hizo Satanás sobre Job?',
          biblicalReference: 'Job 1:9',
          activity: ActivityData(
            question: '¿Cuál fue la pregunta de Satanás que inició la prueba de Job?',
            type: ActivityType.multipleChoice,
            options: [
              '¿Acaso Job es perfecto?',
              '¿Por qué bendices a Job?',
              '¿Acaso teme Job a Dios de balde?',
              '¿Es Job digno de tus bendiciones?',
              '¿Puede Job resistir la prueba?',
            ],
            correctOptionIndex: 2,
            explanation: '¡Correcto! "¿Acaso teme Job a Dios de balde?" - Satanás sugería que Job solo servía a Dios por interés.',
          ),
        ),
        Slide(
          id: 'u2_act_3',
          type: SlideType.activity,
          title: 'Actividad 3: Palabras de Confianza',
          content: 'Las famosas palabras de Job ante la pérdida total.',
          biblicalReference: 'Job 1:21',
          activity: ActivityData(
            question: '¿Qué declaró Job después de perder todo?',
            type: ActivityType.multipleChoice,
            options: [
              '¿Por qué me has abandonado, Señor?',
              'Desnudo salí del vientre de mi madre, y desnudo volveré allá. Jehová dio, y Jehová quitó',
              'Mi Dios, ¿hasta cuándo será esto?',
              'He pecado y merezco este castigo',
              'Maldito sea el día en que nací',
            ],
            correctOptionIndex: 1,
            explanation: '¡Excelente! "Desnudo salí del vientre de mi madre, y desnudo volveré allá. Jehová dio, y Jehová quitó, sea el nombre de Jehová bendito."',
          ),
        ),
        Slide(
          id: 'u2_act_4',
          type: SlideType.activity,
          title: 'Actividad 4: Los Tres Amigos',
          content: 'Identifica a los tres amigos de Job.',
          activity: ActivityData(
            question: '¿Cuáles son los nombres de los tres amigos de Job?',
            type: ActivityType.multipleChoice,
            options: [
              'Pedro, Santiago y Juan',
              'Moisés, Aarón y Miriam',
              'Elifaz, Bildad y Sofar',
              'Daniel, Sadrac y Mesac',
              'Sem, Cam y Jafet',
            ],
            correctOptionIndex: 2,
            explanation: '¡Correcto! Elifaz temanita, Bildad suhita y Sofar naamatita fueron los tres amigos que visitaron a Job.',
          ),
        ),
        Slide(
          id: 'u2_act_5',
          type: SlideType.activity,
          title: 'Actividad 5: La Premisa de los Amigos',
          content: '¿Cuál era el argumento principal de los amigos de Job?',
          activity: ActivityData(
            question: '¿Qué creían los tres amigos sobre el sufrimiento de Job?',
            type: ActivityType.multipleChoice,
            options: [
              'Que Job estaba siendo probado por Dios',
              'Que los grandes sufrimientos se deben a gran pecado',
              'Que Job debía tener más fe',
              'Que era un ataque del enemigo',
              'Que era una lección para otros',
            ],
            correctOptionIndex: 1,
            explanation: '¡Correcto! Los amigos partían de la premisa tradicional: los grandes sufrimientos se deben a gran pecado (teoría de la retribución).',
          ),
        ),
        Slide(
          id: 'u2_act_6',
          type: SlideType.activity,
          title: 'Actividad 6: Eliú',
          content: '¿Qué perspectiva diferente aportó Eliú?',
          biblicalReference: 'Job 33:30',
          activity: ActivityData(
            question: '¿Cuál era la perspectiva distintiva de Eliú sobre el sufrimiento?',
            type: ActivityType.multipleChoice,
            options: [
              'El sufrimiento es siempre castigo por pecado',
              'El sufrimiento puede ser el misericordioso medio de Dios para iluminar el alma',
              'El sufrimiento no tiene explicación',
              'El sufrimiento es obra del diablo únicamente',
              'El sufrimiento indica falta de fe',
            ],
            correctOptionIndex: 1,
            explanation: '¡Correcto! Eliú enfatizó que el sufrimiento puede ser misericordioso para iluminar el alma y originar una relación más perfecta con Dios.',
          ),
        ),
        Slide(
          id: 'u2_act_7',
          type: SlideType.activity,
          title: 'Actividad 7: La Pregunta de Dios',
          content: 'La primera pregunta de Dios a Job desde el torbellino.',
          biblicalReference: 'Job 38:4',
          activity: ActivityData(
            question: '¿Cuál fue la primera pregunta que Dios hizo a Job?',
            type: ActivityType.multipleChoice,
            options: [
              '¿Por qué me cuestionas?',
              '¿Dónde estabas tú cuando yo fundaba la tierra?',
              '¿Quién eres tú para juzgarme?',
              '¿Has sido fiel a mis mandamientos?',
              '¿Por qué no confías en mí?',
            ],
            correctOptionIndex: 1,
            explanation: '¡Excelente! "¿Dónde estabas tú cuando yo fundaba la tierra?" - Dios confronta a Job con su infinita sabiduría y poder creador.',
          ),
        ),
        Slide(
          id: 'u2_act_8',
          type: SlideType.activity,
          title: 'Actividad 8: El Clímax',
          content: 'La expresión culminante de Job.',
          biblicalReference: 'Job 42:5',
          activity: ActivityData(
            question: '¿Cuál fue la declaración que marca el clímax del libro?',
            type: ActivityType.multipleChoice,
            options: [
              'Sé que mis pecados son muchos',
              'He aprendido mi lección',
              'De oídas te había oído; mas ahora mis ojos te ven',
              'Ahora entiendo tu justicia',
              'Prometo nunca más cuestionar',
            ],
            correctOptionIndex: 2,
            explanation: '¡Perfecto! "De oídas te había oído; mas ahora mis ojos te ven" - Job pasó de conocimiento teórico a experiencia personal con Dios.',
          ),
        ),
        Slide(
          id: 'u2_act_9',
          type: SlideType.activity,
          title: 'Actividad 9: La Restauración',
          content: '¿Cómo restauró Dios a Job?',
          biblicalReference: 'Job 42:10',
          activity: ActivityData(
            question: '¿Cuánto le dio Dios a Job al final del libro?',
            type: ActivityType.multipleChoice,
            options: [
              'Lo mismo que tenía antes',
              'El doble de todo lo que había tenido',
              'Menos de lo que tenía, pero con paz',
              'Solo salud, sin riquezas',
              'Riquezas espirituales únicamente',
            ],
            correctOptionIndex: 1,
            explanation: '¡Correcto! Dios otorgó a Job "el doble de todo lo que había tenido antes" (Job 42:10), demostrando su superabundante bondad.',
          ),
        ),
        Slide(
          id: 'u2_act_10',
          type: SlideType.activity,
          title: 'Actividad 10: Preguntas en Cristo',
          content: '¿Qué pregunta de Job encuentra respuesta en el Nuevo Testamento?',
          biblicalReference: 'Job 14:14',
          activity: ActivityData(
            question: '"Si el hombre muriere, ¿volverá a vivir?" ¿Dónde encuentra respuesta esta pregunta?',
            type: ActivityType.multipleChoice,
            options: [
              'En la promesa a Abraham',
              'En la ley de Moisés',
              'En las palabras de Jesús: "Yo soy la resurrección y la vida"',
              'En los Salmos de David',
              'En las profecías de Isaías',
            ],
            correctOptionIndex: 2,
            explanation: '¡Excelente! Jesús responde: "Yo soy la resurrección y la vida; el que cree en mí, aunque esté muerto, vivirá" (Juan 11:25).',
          ),
        ),
        Slide(
          id: 'u2_act_11',
          type: SlideType.activity,
          title: 'Actividad 11: Satanás en Job',
          content: '¿Cómo se presenta a Satanás en el libro de Job?',
          activity: ActivityData(
            question: '¿Cuál es la característica principal de Satanás en el libro de Job?',
            type: ActivityType.multipleChoice,
            options: [
              'Como una serpiente engañadora',
              'Como un león rugiente',
              'Como un espíritu escéptico, cínico, deseoso de acusar al hombre ante Dios',
              'Como un ángel de luz',
              'Como un adversario violento',
            ],
            correctOptionIndex: 2,
            explanation: '¡Correcto! Satanás se presenta como un espíritu escéptico, cínico, que no puede creer que los hombres sirvan a Dios desinteresadamente.',
          ),
        ),
        Slide(
          id: 'u2_act_12',
          type: SlideType.activity,
          title: 'Actividad 12: La Gran Lección',
          content: '¿Cuál es la enseñanza central del libro de Job?',
          activity: ActivityData(
            question: 'El libro de Job va más allá del problema del sufrimiento. ¿A qué llega profundamente?',
            type: ActivityType.multipleChoice,
            options: [
              'A la necesidad de obedecer los mandamientos',
              'A las relaciones personales del hombre con Dios, que no es explicación sino experiencia',
              'A la importancia de los rituales religiosos',
              'A la necesidad de confesar los pecados',
              'A la importancia de tener buenos amigos',
            ],
            correctOptionIndex: 1,
            explanation: '¡Perfecto! El libro llega profundamente al problema de las relaciones personales con Dios, que al final no es algo que tenga una explicación sino una experiencia.',
          ),
        ),
        Slide(
          id: 'u2_act_13',
          type: SlideType.activity,
          title: 'Actividad 13: Estructura del Libro',
          content: '¿Cuántos ciclos de discursos hay entre Job y sus amigos?',
          activity: ActivityData(
            question: '¿Cuántos ciclos de discursos componen el debate entre Job y sus tres amigos?',
            type: ActivityType.multipleChoice,
            options: [
              'Un ciclo',
              'Dos ciclos',
              'Tres ciclos',
              'Cuatro ciclos',
              'Cinco ciclos',
            ],
            correctOptionIndex: 2,
            explanation: '¡Correcto! Hay tres ciclos de discursos: Primer ciclo (caps. 3-14), Segundo ciclo (caps. 15-21), y Tercer ciclo (caps. 22-31).',
          ),
        ),
        Slide(
          id: 'u2_act_14',
          type: SlideType.activity,
          title: 'Actividad 14: El Mediador',
          content: 'Job clamaba por un árbitro entre él y Dios.',
          biblicalReference: 'Job 9:33',
          activity: ActivityData(
            question: 'Job se lamentaba: "No hay entre nosotros árbitro." ¿Quién es ese mediador según el NT?',
            type: ActivityType.multipleChoice,
            options: [
              'Los ángeles',
              'Moisés',
              'Los profetas',
              'Jesucristo hombre',
              'El Espíritu Santo',
            ],
            correctOptionIndex: 3,
            explanation: '¡Excelente! "Hay un solo Dios, y un solo mediador entre Dios y los hombres, Jesucristo hombre" (1 Timoteo 2:5).',
          ),
        ),
        Slide(
          id: 'u2_act_15',
          type: SlideType.activity,
          title: 'Actividad 15: Reflexión Final',
          content: '¿Por qué Dios reprendió a los amigos de Job?',
          biblicalReference: 'Job 42:7',
          activity: ActivityData(
            question: '¿Qué dijo Dios sobre los tres amigos de Job?',
            type: ActivityType.multipleChoice,
            options: [
              'Que habían sido buenos consejeros',
              'Que no habían hablado con verdad de Él, como su siervo Job',
              'Que debían aprender más sobre la ley',
              'Que habían sido demasiado duros con Job',
              'Que necesitaban más experiencia',
            ],
            correctOptionIndex: 1,
            explanation: '¡Correcto! Dios dijo: "No habéis hablado con verdad de mí, como mi siervo Job" - Los amigos defendían una teología incorrecta sobre el sufrimiento.',
          ),
        ),
        // ============================================================
        // SOPA DE LETRAS INTERACTIVA - ACTIVIDAD ESPECIAL
        // ============================================================
        Slide(
          id: 'u2_act_sopa',
          type: SlideType.activity,
          title: '🎯 Sopa de Letras: El Libro de Job',
          content: 'Encuentra las 20 palabras clave del libro de Job. ¡El estudiante que termine en menor tiempo gana!',
          activity: ActivityData(
            question: 'Encuentra todas las palabras relacionadas con el libro de Job',
            type: ActivityType.wordSearch,
            options: [
              // 20 palabras clave del libro de Job
              'JOB',
              'SATANAS',
              'ELIFAZ',
              'BILDAD',
              'SOFAR',
              'ELIU',
              'DIOS',
              'TORBELLINO',
              'REDENTOR',
              'SUFRIMIENTO',
              'FE',
              'PACIENCIA',
              'PRUEBA',
              'SABIDURIA',
              'RESTAURACION',
              'JUSTO',
              'PROLOGO',
              'EPILOGO',
              'MEDIADOR',
              'SHADDAI',
            ],
            correctOptionIndex: 0,
            percentageValue: 20.0, // Vale más por ser actividad especial
            explanation: '¡Felicidades! Has demostrado conocer los conceptos clave del libro de Job. Recuerda: "De oídas te había oído; mas ahora mis ojos te ven" (Job 42:5).',
          ),
        ),
      ],
    ),
  ],
);

final List<ClassSession> availableUnits = [unit1Session, unit2Session];
