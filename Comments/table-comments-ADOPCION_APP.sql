USE ADOPCION_APP;

-- ==========================================
-- 1. TABLAS DE DIRECCIONES Y UBICACIÓN
-- ==========================================

ALTER TABLE Country
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del país',
    MODIFY name VARCHAR(60) NOT NULL COMMENT 'Nombre del país',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';

ALTER TABLE Province
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la provincia',
    MODIFY idCountry INT(7) NOT NULL COMMENT 'FK: País al que pertenece la provincia',
    MODIFY name VARCHAR(60) NOT NULL COMMENT 'Nombre de la provincia',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';

ALTER TABLE Canton
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del cantón',
    MODIFY idProvince INT(7) NOT NULL COMMENT 'FK: Provincia a la que pertenece el cantón',
    MODIFY name VARCHAR(60) NOT NULL COMMENT 'Nombre del cantón',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';

ALTER TABLE District
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del distrito',
    MODIFY idCanton INT(7) NOT NULL COMMENT 'FK: Cantón al que pertenece el distrito',
    MODIFY name VARCHAR(60) NOT NULL COMMENT 'Nombre del distrito',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';

ALTER TABLE Location
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la ubicación',
    MODIFY idDistrict INT(7) NOT NULL COMMENT 'FK: Distrito al que pertenece la ubicación',
    MODIFY address VARCHAR(255) NOT NULL COMMENT 'Dirección exacta o señas',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';


-- ==========================================
-- 2. TABLAS DE PERSONAS Y CONTACTOS
-- ==========================================

ALTER TABLE Person
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la persona',
    MODIFY idLocation INT(7) NOT NULL COMMENT 'FK: Ubicación donde reside la persona',
    MODIFY firstName VARCHAR(30) NOT NULL COMMENT 'Primer nombre',
    MODIFY middleName VARCHAR(30) COMMENT 'Segundo nombre (opcional)',
    MODIFY firstLastName VARCHAR(30) NOT NULL COMMENT 'Primer apellido',
    MODIFY secondLastName VARCHAR(30) COMMENT 'Segundo apellido (opcional)',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';

ALTER TABLE BlackList
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la entrada en la lista negra',
    MODIFY idPerson INT(7) NOT NULL COMMENT 'FK: Persona que está en la lista negra',
    MODIFY blackListDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha en la que se agregó a la lista',
    MODIFY blackListReason VARCHAR(255) NOT NULL COMMENT 'Motivo por el cual se agregó a la lista negra',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';

ALTER TABLE ContactEmail
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del correo',
    MODIFY idPerson INT(7) NOT NULL COMMENT 'FK: Persona dueña del correo',
    MODIFY email VARCHAR(254) COMMENT 'Dirección de correo electrónico (límite RFC 5321)',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';

ALTER TABLE ContactNumber
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del teléfono',
    MODIFY idPerson INT(7) NOT NULL COMMENT 'FK: Persona dueña del teléfono',
    MODIFY phoneNumber VARCHAR(254) NOT NULL COMMENT 'Número de teléfono (límite norma E.164)',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';


-- ==========================================
-- 3. TABLAS DE USUARIO Y SEGURIDAD
-- ==========================================

ALTER TABLE UserStatus
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del estado del usuario',
    MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del estado (Activo, Inactivo, Suspendido, etc.)',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';

ALTER TABLE `Role`
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del rol',
    MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del rol (Admin, Usuario, Rescatista, etc.)',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';

ALTER TABLE `User`
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del usuario',
    MODIFY idPerson INT(7) NOT NULL COMMENT 'FK: Persona asociada al usuario',
    MODIFY idRole INT(7) NOT NULL COMMENT 'FK: Rol del usuario en el sistema',
    MODIFY idUserStatus INT(7) NOT NULL COMMENT 'FK: Estado actual del usuario',
    MODIFY username VARCHAR(50) NOT NULL COMMENT 'Nombre de usuario para iniciar sesión (Único)',
    MODIFY password VARCHAR(64) NOT NULL COMMENT 'Contraseña encriptada usando SHA-256 (64 caracteres)',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';


-- ==========================================
-- 4. TABLAS DE CATÁLOGOS DE MASCOTAS
-- ==========================================

ALTER TABLE PetSize MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del tamaño (Ej: Pequeño, Mediano)', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del tamaño', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE PetColor MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del color', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del color', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE PetSeverity MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la severidad de la condición', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nivel de severidad', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE PetEnergy MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del nivel de energía', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nivel de energía (Alta, Media, Baja)', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE PetTrainability MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de entrenabilidad', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nivel de facilidad para entrenar', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE PetStatus MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del estado de la mascota (Perdida, Encontrada, En adopción)', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del estado', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE PetType MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del tipo de mascota (Perro, Gato, etc.)', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del tipo de mascota', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE PetBreed
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la raza',
    MODIFY idPetType INT(7) NOT NULL COMMENT 'FK: Tipo de mascota al que pertenece la raza',
    MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre de la raza',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';


-- ==========================================
-- 5. TABLAS DE MASCOTAS Y SALUD
-- ==========================================

ALTER TABLE Veterinarian
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del veterinario',
    MODIFY idPerson INT(7) NOT NULL COMMENT 'FK: Persona asociada al veterinario',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Pet
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la mascota',
    MODIFY idLocation INT(7) NOT NULL COMMENT 'FK: Ubicación donde se encuentra/perdió/encontró',
    MODIFY idPerson INT(7) NOT NULL COMMENT 'FK: Persona reportante o dueña',
    MODIFY idPetBreed INT(7) NOT NULL COMMENT 'FK: Raza de la mascota',
    MODIFY idPetSize INT(7) NOT NULL COMMENT 'FK: Tamaño de la mascota',
    MODIFY idPetColor INT(7) NOT NULL COMMENT 'FK: Color de la mascota',
    MODIFY idPetSeverity INT(7) NOT NULL COMMENT 'FK: Severidad de la condición',
    MODIFY idPetEnergy INT(7) NOT NULL COMMENT 'FK: Nivel de energía',
    MODIFY idPetTrainability INT(7) NOT NULL COMMENT 'FK: Nivel de entrenabilidad',
    MODIFY idPetStatus INT(7) NOT NULL COMMENT 'FK: Estado actual de la mascota',
    MODIFY idVeterinarian INT(7) NOT NULL COMMENT 'FK: Veterinario a cargo',
    MODIFY chipId INT(7) NOT NULL COMMENT 'Identificador del chip de la mascota (Único)',
    MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre de la mascota',
    MODIFY requiresSpace TINYINT(1) NOT NULL COMMENT 'Indica si requiere espacio (1=Sí, 0=No)',
    MODIFY notesDescription VARCHAR(255) NOT NULL COMMENT 'Descripción o notas adicionales',
    MODIFY abandonmentNotesDescription VARCHAR(255) COMMENT 'Notas sobre abandono (si aplica)',
    MODIFY estimatedAge INT(7) COMMENT 'Edad estimada en meses o años',
    MODIFY eventDate DATE COMMENT 'Fecha del evento (pérdida o hallazgo)',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Medication MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del medicamento', MODIFY name VARCHAR(50) NOT NULL COMMENT 'Nombre del medicamento', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Treatment MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del tratamiento', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del tratamiento', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Disease MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la enfermedad', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre de la enfermedad', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Medication_x_treatment
    MODIFY idMedication INT(7) COMMENT 'FK: Medicamento',
    MODIFY idTreatment INT(7) COMMENT 'FK: Tratamiento',
    MODIFY dosage VARCHAR(100) NOT NULL COMMENT 'Dosis recomendada del medicamento',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Treatment_x_disease
    MODIFY idDisease INT(7) COMMENT 'FK: Enfermedad',
    MODIFY idTreatment INT(7) COMMENT 'FK: Tratamiento',
    MODIFY timeLength VARCHAR(100) NOT NULL COMMENT 'Duración estimada del tratamiento',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Disease_x_pet
    MODIFY idDisease INT(7) COMMENT 'FK: Enfermedad',
    MODIFY idPet INT(7) COMMENT 'FK: Mascota afectada',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';


-- ==========================================
-- 6. TABLAS DE DONACIONES
-- ==========================================

ALTER TABLE DonationType MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del tipo de donación', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del tipo de donación (Monetaria, Alimento, etc.)', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE CurrencyType MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del tipo de moneda', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre de la moneda (CRC, USD, etc.)', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE AnimalWelfareAssociation
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la asociación',
    MODIFY idLocation INT(7) NOT NULL COMMENT 'FK: Ubicación física de la asociación',
    MODIFY name VARCHAR(60) NOT NULL COMMENT 'Nombre de la asociación de bienestar animal',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Reward
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la recompensa',
    MODIFY idPet INT(7) NOT NULL COMMENT 'FK: Mascota por la que se ofrece recompensa',
    MODIFY idCurrencyType INT(7) NOT NULL COMMENT 'FK: Moneda de la recompensa',
    MODIFY amount INT(9) NOT NULL COMMENT 'Monto ofrecido como recompensa',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Donation
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la donación',
    MODIFY idPerson INT(7) NOT NULL COMMENT 'FK: Persona que realiza la donación',
    MODIFY idDonationType INT(7) NOT NULL COMMENT 'FK: Tipo de donación',
    MODIFY idCurrencyType INT(7) NOT NULL COMMENT 'FK: Tipo de moneda',
    MODIFY idReward INT(7) NOT NULL COMMENT 'FK: Recompensa asociada (si aplica)',
    MODIFY donationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha y hora de la donación',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE DonationDetail
    MODIFY idAnimalWelfareAssociation INT(7) COMMENT 'FK: Asociación que recibe la donación',
    MODIFY idDonation INT(7) COMMENT 'FK: Donación principal',
    MODIFY amount INT(9) NOT NULL COMMENT 'Monto asignado a esta asociación',
    MODIFY percentage INT(3) NOT NULL COMMENT 'Porcentaje del total de la donación',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';


-- ==========================================
-- 7. TABLAS DE ADOPCIÓN Y HOGARES
-- ==========================================

ALTER TABLE ExerciseTime MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del tiempo de ejercicio', MODIFY value VARCHAR(30) NOT NULL COMMENT 'Valor o descripción del tiempo de ejercicio', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE HouseType MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del tipo de vivienda', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del tipo de vivienda (Casa, Apartamento)', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE House
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la vivienda',
    MODIFY idHouseType INT(7) NOT NULL COMMENT 'FK: Tipo de vivienda',
    MODIFY hasYard TINYINT(1) NOT NULL COMMENT 'Indica si tiene patio (1=Sí, 0=No)',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Adopter
    MODIFY idAdopter INT(7) COMMENT 'PK y FK: Persona que adopta',
    MODIFY idHouse INT(7) NOT NULL COMMENT 'FK: Vivienda del adoptante',
    MODIFY idExerciseTime INT(7) NOT NULL COMMENT 'FK: Tiempo de ejercicio que puede ofrecer',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Adoption
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la adopción',
    MODIFY idPerson INT(7) NOT NULL COMMENT 'FK: Persona que reportó o donó la mascota',
    MODIFY idAdopter INT(7) NOT NULL COMMENT 'FK: Adoptante',
    MODIFY idPet INT(7) NOT NULL COMMENT 'FK: Mascota adoptada',
    MODIFY adoptionDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha y hora de la adopción',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE FollowUp
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del seguimiento',
    MODIFY idAdoption INT(7) NOT NULL COMMENT 'FK: Adopción a la que pertenece el seguimiento',
    MODIFY comments VARCHAR(255) NOT NULL COMMENT 'Comentarios o notas del seguimiento',
    MODIFY followUpDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha del seguimiento',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE PetOwnerRating
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la calificación',
    MODIFY idAdoption INT(7) NOT NULL COMMENT 'FK: Adopción evaluada',
    MODIFY rating INT(2) NOT NULL COMMENT 'Puntaje de calificación (ej. 1 a 5)',
    MODIFY notes VARCHAR(255) NOT NULL COMMENT 'Notas o justificación de la nota',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE OtherPet
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único',
    MODIFY idPetBreed INT(7) NOT NULL COMMENT 'FK: Raza de la otra mascota',
    MODIFY idAdopter INT(7) NOT NULL COMMENT 'FK: Adoptante dueño de la otra mascota',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE PhotoType MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del tipo de foto', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del tipo (Perfil, Evidencia, etc.)', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE Photo
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la foto',
    MODIFY idFollowUp INT(7) NOT NULL COMMENT 'FK: Seguimiento al que pertenece la foto',
    MODIFY idPet INT(7) NOT NULL COMMENT 'FK: Mascota fotografiada',
    MODIFY idPhotoType INT(7) NOT NULL COMMENT 'FK: Tipo de foto',
    MODIFY photoURL VARCHAR(2048) NOT NULL COMMENT 'URL de la imagen (límite 2048 caracteres)',
    MODIFY uploadDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de subida',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE FosterHomeStatus MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del estado del hogar', MODIFY name VARCHAR(30) NOT NULL COMMENT 'Nombre del estado (Disponible, Lleno, etc.)', MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación', MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por', MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización', MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE FosterHome
    MODIFY idFosterHome INT(7) COMMENT 'PK y FK: Persona encargada del hogar temporal',
    MODIFY idLocation INT(7) NOT NULL COMMENT 'FK: Ubicación del hogar temporal',
    MODIFY idFosterHomeStatus INT(7) NOT NULL COMMENT 'FK: Estado actual del hogar',
    MODIFY maxCapacity INT(3) NOT NULL COMMENT 'Capacidad máxima de mascotas',
    MODIFY requiresFoodDonation TINYINT(1) NOT NULL COMMENT 'Indica si requiere donación de alimento (1=Sí)',
    MODIFY petCount INT(3) NOT NULL COMMENT 'Cantidad actual de mascotas en el hogar',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE FosterHome_x_petSize
    MODIFY idFosterHome INT(7) COMMENT 'FK: Hogar temporal',
    MODIFY idPetSize INT(7) COMMENT 'FK: Tamaño de mascota permitido',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';

ALTER TABLE FosterHome_x_petType
    MODIFY idFosterHome INT(7) COMMENT 'FK: Hogar temporal',
    MODIFY idPetType INT(7) COMMENT 'FK: Tipo de mascota permitido',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Creado por',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Actualizado por';


-- ==========================================
-- 8. TABLAS DE MATCH Y PARÁMETROS
-- ==========================================
ALTER TABLE PetMatch
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único de la coincidencia',
    MODIFY idLostPet INT(7) NOT NULL COMMENT 'FK: ID de la mascota perdida',
    MODIFY idFoundPet INT(7) NOT NULL COMMENT 'FK: ID de la mascota encontrada',
    MODIFY matchDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha en la que se detectó la coincidencia',
    MODIFY matchScore DECIMAL(5,2) NOT NULL COMMENT 'Puntaje de similitud entre ambas mascotas (0.00 a 100.00)',
    MODIFY notified TINYINT(1) DEFAULT 0 COMMENT 'Indica si los dueños fueron notificados (0=No, 1=Sí)';

ALTER TABLE Parameter
    MODIFY id INT(7) AUTO_INCREMENT COMMENT 'Identificador único del parámetro',
    MODIFY name VARCHAR(50) NOT NULL COMMENT 'Nombre clave del parámetro (ej. MATCH_JOB_INTERVAL_HOURS)',
    MODIFY description VARCHAR(255) NOT NULL COMMENT 'Descripción de la funcionalidad del parámetro',
    MODIFY textValue VARCHAR(255) COMMENT 'Valor del parámetro cuando su tipo es texto',
    MODIFY numberValue DECIMAL(9,2) COMMENT 'Valor del parámetro cuando su tipo es numérico (ej. horas de intervalo, puntajes)',
    MODIFY creationDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'Fecha de creación del registro',
    MODIFY createdBy VARCHAR(30) DEFAULT 'ADOPCION_APP' NOT NULL COMMENT 'Usuario que creó el registro',
    MODIFY updatedDate DATETIME COMMENT 'Fecha de la última actualización',
    MODIFY updatedBy VARCHAR(30) COMMENT 'Usuario que realizó la última actualización';

COMMIT;