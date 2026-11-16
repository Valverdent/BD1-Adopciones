-- -------------------------------------------------------------------
-- -------------- Script de inserción de datos básicos ---------------
-- -------------------------------------------------------------------

-- DonationType
INSERT INTO DonationType (name) VALUES ('Voluntaria');
INSERT INTO DonationType (name) VALUES ('Recompensa');

-- CurrencyType
INSERT INTO CurrencyType (name) VALUES ('Colones');
INSERT INTO CurrencyType (name) VALUES ('Dolares');

-- PetType
INSERT INTO PetType (name) VALUES ('Perro');
INSERT INTO PetType (name) VALUES ('Gato');
INSERT INTO PetType (name) VALUES ('Ave');
INSERT INTO PetType (name) VALUES ('Conejo');
INSERT INTO PetType (name) VALUES ('Roedor');
INSERT INTO PetType (name) VALUES ('Reptil');
INSERT INTO PetType (name) VALUES ('Otro');

-- PetBreed
-- Perro (idPetType = 1)
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Labrador Retriever');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Golden Retriever');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Pastor Alemán');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Chihuahua');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Poodle');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Bulldog');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Beagle');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Rottweiler');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Husky Siberiano');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Pitbull');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Schnauzer');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Dálmata');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Boxer');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Shih Tzu');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Pug');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Salchicha');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Doberman');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Border Collie');
INSERT INTO PetBreed (idPetType, name) VALUES (1, 'Raza única');

-- Gato (idPetType = 2)
INSERT INTO PetBreed (idPetType, name) VALUES (2, 'Siamés');
INSERT INTO PetBreed (idPetType, name) VALUES (2, 'Persa');
INSERT INTO PetBreed (idPetType, name) VALUES (2, 'Angora');
INSERT INTO PetBreed (idPetType, name) VALUES (2, 'Maine Coon');
INSERT INTO PetBreed (idPetType, name) VALUES (2, 'Bengalí');
INSERT INTO PetBreed (idPetType, name) VALUES (2, 'Esfinge');
INSERT INTO PetBreed (idPetType, name) VALUES (2, 'Británico de pelo corto');
INSERT INTO PetBreed (idPetType, name) VALUES (2, 'Ragdoll');
INSERT INTO PetBreed (idPetType, name) VALUES (2, 'Raza única');

-- Ave (idPetType = 3)
INSERT INTO PetBreed (idPetType, name) VALUES (3, 'Canario');
INSERT INTO PetBreed (idPetType, name) VALUES (3, 'Periquito');
INSERT INTO PetBreed (idPetType, name) VALUES (3, 'Cacatúa');
INSERT INTO PetBreed (idPetType, name) VALUES (3, 'Agapornis');
INSERT INTO PetBreed (idPetType, name) VALUES (3, 'Loro');
INSERT INTO PetBreed (idPetType, name) VALUES (3, 'Ninfa');
INSERT INTO PetBreed (idPetType, name) VALUES (3, 'Raza única');

-- Conejo (idPetType = 4)
INSERT INTO PetBreed (idPetType, name) VALUES (4, 'Cabeza de León');
INSERT INTO PetBreed (idPetType, name) VALUES (4, 'Enano');
INSERT INTO PetBreed (idPetType, name) VALUES (4, 'Holandés');
INSERT INTO PetBreed (idPetType, name) VALUES (4, 'Angora');
INSERT INTO PetBreed (idPetType, name) VALUES (4, 'Raza única');

-- Roedor (idPetType = 5)
INSERT INTO PetBreed (idPetType, name) VALUES (5, 'Hámster');
INSERT INTO PetBreed (idPetType, name) VALUES (5, 'Cobaya');
INSERT INTO PetBreed (idPetType, name) VALUES (5, 'Ratón');
INSERT INTO PetBreed (idPetType, name) VALUES (5, 'Rata');
INSERT INTO PetBreed (idPetType, name) VALUES (5, 'Chinchilla');
INSERT INTO PetBreed (idPetType, name) VALUES (5, 'Jerbo');
INSERT INTO PetBreed (idPetType, name) VALUES (5, 'Raza única');

-- Reptil (idPetType = 6)
INSERT INTO PetBreed (idPetType, name) VALUES (6, 'Iguana');
INSERT INTO PetBreed (idPetType, name) VALUES (6, 'Tortuga');
INSERT INTO PetBreed (idPetType, name) VALUES (6, 'Gecko');
INSERT INTO PetBreed (idPetType, name) VALUES (6, 'Serpiente');
INSERT INTO PetBreed (idPetType, name) VALUES (6, 'Raza única');

-- Otro (idPetType = 7)
INSERT INTO PetBreed (idPetType, name) VALUES (7, 'Raza única');

-- PetSize
INSERT INTO PetSize (name) VALUES ('Pequeño');
INSERT INTO PetSize (name) VALUES ('Mediano');
INSERT INTO PetSize (name) VALUES ('Grande');
INSERT INTO PetSize (name) VALUES ('Muy Grande');

-- PetColor
INSERT INTO PetColor (name) VALUES ('Blanco');
INSERT INTO PetColor (name) VALUES ('Negro');
INSERT INTO PetColor (name) VALUES ('Café');
INSERT INTO PetColor (name) VALUES ('Gris');
INSERT INTO PetColor (name) VALUES ('Beige');
INSERT INTO PetColor (name) VALUES ('Dorado');
INSERT INTO PetColor (name) VALUES ('Naranja');
INSERT INTO PetColor (name) VALUES ('Crema');
INSERT INTO PetColor (name) VALUES ('Canela');
INSERT INTO PetColor (name) VALUES ('Atigrado');
INSERT INTO PetColor (name) VALUES ('Bicolor');
INSERT INTO PetColor (name) VALUES ('Tricolor');
INSERT INTO PetColor (name) VALUES ('Manchado');
INSERT INTO PetColor (name) VALUES ('Otro');

-- PetSeverity
INSERT INTO PetSeverity (name) VALUES ('Crítico');
INSERT INTO PetSeverity (name) VALUES ('Mal estado');
INSERT INTO PetSeverity (name) VALUES ('Buen estado');

-- PetEnergy
INSERT INTO PetEnergy (name) VALUES ('Atlético');
INSERT INTO PetEnergy (name) VALUES ('Corredor');
INSERT INTO PetEnergy (name) VALUES ('Caminador');
INSERT INTO PetEnergy (name) VALUES ('Para ver TV');
INSERT INTO PetEnergy (name) VALUES ('No es importante');

-- PetTrainability
INSERT INTO PetTrainability (name) VALUES ('Muy fácil');
INSERT INTO PetTrainability (name) VALUES ('Fácil');
INSERT INTO PetTrainability (name) VALUES ('Moderada');
INSERT INTO PetTrainability (name) VALUES ('Difícil');

-- PhotoType
INSERT INTO PhotoType (name) VALUES ('Antes (abandono)');
INSERT INTO PhotoType (name) VALUES ('Después (recuperación)');
INSERT INTO PhotoType (name) VALUES ('Adoptante con mascota');
INSERT INTO PhotoType (name) VALUES ('Nueva vida');
INSERT INTO PhotoType (name) VALUES ('General');

-- Disease
INSERT INTO Disease (name) VALUES ('Parvovirus');
INSERT INTO Disease (name) VALUES ('Moquillo');
INSERT INTO Disease (name) VALUES ('Rabia');
INSERT INTO Disease (name) VALUES ('Leptospirosis');
INSERT INTO Disease (name) VALUES ('Leishmaniasis');
INSERT INTO Disease (name) VALUES ('Dirofilariasis');
INSERT INTO Disease (name) VALUES ('Erliquiosis');
INSERT INTO Disease (name) VALUES ('Sarna');
INSERT INTO Disease (name) VALUES ('Giardiasis');
INSERT INTO Disease (name) VALUES ('Tos de las perreras');
INSERT INTO Disease (name) VALUES ('Hepatitis infecciosa canina');
INSERT INTO Disease (name) VALUES ('Leucemia felina (VLFe)');
INSERT INTO Disease (name) VALUES ('Inmunodeficiencia felina (VIF)');
INSERT INTO Disease (name) VALUES ('Panleucopenia felina');
INSERT INTO Disease (name) VALUES ('Rinotraqueítis felina');
INSERT INTO Disease (name) VALUES ('Dermatofitosis (hongos)');
INSERT INTO Disease (name) VALUES ('Parásitos intestinales');
INSERT INTO Disease (name) VALUES ('Infestación de pulgas');
INSERT INTO Disease (name) VALUES ('Infestación de garrapatas');
INSERT INTO Disease (name) VALUES ('Otitis');
INSERT INTO Disease (name) VALUES ('Desnutrición severa');
INSERT INTO Disease (name) VALUES ('Trauma / fracturas');
INSERT INTO Disease (name) VALUES ('Ninguna conocida');

-- Treatment
INSERT INTO Treatment (name) VALUES ('Vacunación');
INSERT INTO Treatment (name) VALUES ('Desparasitación');
INSERT INTO Treatment (name) VALUES ('Antibioticoterapia');
INSERT INTO Treatment (name) VALUES ('Fluidoterapia');
INSERT INTO Treatment (name) VALUES ('Cirugía');
INSERT INTO Treatment (name) VALUES ('Baño medicado');
INSERT INTO Treatment (name) VALUES ('Alimentación especial');
INSERT INTO Treatment (name) VALUES ('Control del dolor');
INSERT INTO Treatment (name) VALUES ('Antiparasitario externo');

-- Medication
INSERT INTO Medication (name) VALUES ('Amoxicilina');
INSERT INTO Medication (name) VALUES ('Doxiciclina');
INSERT INTO Medication (name) VALUES ('Metronidazol');
INSERT INTO Medication (name) VALUES ('Ivermectina');
INSERT INTO Medication (name) VALUES ('Praziquantel');
INSERT INTO Medication (name) VALUES ('Fenbendazol');
INSERT INTO Medication (name) VALUES ('Meloxicam');
INSERT INTO Medication (name) VALUES ('Prednisolona');
INSERT INTO Medication (name) VALUES ('Suero oral');

-- HouseType
INSERT INTO HouseType (name) VALUES ('Casa');
INSERT INTO HouseType (name) VALUES ('Apartamento');
INSERT INTO HouseType (name) VALUES ('Condominio');
INSERT INTO HouseType (name) VALUES ('Finca');

-- ExerciseTime
INSERT INTO ExerciseTime (value) VALUES ('Menos de 30 minutos');
INSERT INTO ExerciseTime (value) VALUES ('30 a 60 minutos');
INSERT INTO ExerciseTime (value) VALUES ('1 a 2 horas');
INSERT INTO ExerciseTime (value) VALUES ('Más de 2 horas');

-- FosterHomeStatus
INSERT INTO FosterHomeStatus (name) VALUES ('Disponible');
INSERT INTO FosterHomeStatus (name) VALUES ('Lleno');

COMMIT;