--================================================
--==== Triggers relacionados al usuario ====
--================================================

CREATE OR REPLACE TRIGGER beforeSaveUserStatus
BEFORE INSERT OR UPDATE OR DELETE ON UserStatus
FOR EACH ROW
BEGIN
    -- BLOQUE PARA INSERCIONES
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP',                 -- pcScheme
            'UserStatus',                   -- pcTableName
            NULL,                           -- pcFieldName
            NULL,                           -- pcOldValue
            NULL,                           -- pcNewValue
            TO_CHAR(:NEW.id),               -- pcRecordId
            'New tuple insertion',          -- pcChangeDescription
            USER                            -- pcCreatedBy
        );
    END IF;
    
    -- BLOQUE PARA ACTUALIZACIONES
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP',
                'UserStatus',
                'name',
                TO_CHAR(:OLD.name),
                TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id),
                'Changed status name',
                USER
            );
        END IF;
    END IF;

    -- BLOQUE PARA ELIMINACIONES
    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP',                 -- pcScheme
            'UserStatus',                   -- pcTableName
            NULL,                           -- pcFieldName
            NULL,                           -- pcOldValue
            NULL,                           -- pcNewValue
            TO_CHAR(:OLD.id),               -- pcRecordId
            'Tuple deletion',               -- pcChangeDescription
            USER                            -- pcCreatedBy
        );
    END IF;
END beforeSaveUserStatus;
/


CREATE OR REPLACE TRIGGER beforeSaveRole
BEFORE INSERT OR UPDATE OR DELETE ON "Role"
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Role', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Role', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed role name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Role', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveRole;
/


CREATE OR REPLACE TRIGGER beforeSaveUser
BEFORE INSERT OR UPDATE OR DELETE ON "User"
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'User', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idPerson') AND (:OLD.idPerson != :NEW.idPerson) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'User', 'idPerson',
                TO_CHAR(:OLD.idPerson), TO_CHAR(:NEW.idPerson),
                TO_CHAR(:NEW.id), 'Changed id of associated person', USER
            );
        END IF;

        IF UPDATING('idRole') AND (:OLD.idRole != :NEW.idRole) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'User', 'idRole',
                TO_CHAR(:OLD.idRole), TO_CHAR(:NEW.idRole),
                TO_CHAR(:NEW.id), 'Changed id of associated role', USER
            );
        END IF;

        IF UPDATING('idUserStatus') AND (:OLD.idUserStatus != :NEW.idUserStatus) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'User', 'idUserStatus',
                TO_CHAR(:OLD.idUserStatus), TO_CHAR(:NEW.idUserStatus),
                TO_CHAR(:NEW.id), 'Changed id of associated user status', USER
            );
        END IF;

        IF UPDATING('username') AND (:OLD.username != :NEW.username) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'User', 'username',
                TO_CHAR(:OLD.username), TO_CHAR(:NEW.username),
                TO_CHAR(:NEW.id), 'Changed username', USER
            );
        END IF;

        IF UPDATING('password') AND (:OLD.password != :NEW.password) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'User', 'password',
                TO_CHAR(:OLD.password), TO_CHAR(:NEW.password),
                TO_CHAR(:NEW.id), 'Changed password', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'User', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveUser;
/


CREATE OR REPLACE TRIGGER beforeSaveBlackList
BEFORE INSERT OR UPDATE OR DELETE ON BlackList
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'BlackList', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idPerson') AND (:OLD.idPerson != :NEW.idPerson) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'BlackList', 'idPerson',
                TO_CHAR(:OLD.idPerson), TO_CHAR(:NEW.idPerson),
                TO_CHAR(:NEW.id), 'Changed id of associated person', USER
            );
        END IF;

        IF UPDATING('blackListDate') AND (:OLD.blackListDate != :NEW.blackListDate) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'BlackList', 'blackListDate',
                TO_CHAR(:OLD.blackListDate), TO_CHAR(:NEW.blackListDate),
                TO_CHAR(:NEW.id), 'Changed date when blacklist record was created', USER
            );
        END IF;

        IF UPDATING('blackListReason') AND (:OLD.blackListReason != :NEW.blackListReason) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'BlackList', 'blackListReason',
                TO_CHAR(:OLD.blackListReason), TO_CHAR(:NEW.blackListReason),
                TO_CHAR(:NEW.id), 'Changed reason why blacklist record was created', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'BlackList', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveBlackList;
/


CREATE OR REPLACE TRIGGER beforeSavePerson
BEFORE INSERT OR UPDATE OR DELETE ON Person
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Person', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idLocation') AND (:OLD.idLocation != :NEW.idLocation) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Person', 'idLocation',
                TO_CHAR(:OLD.idLocation), TO_CHAR(:NEW.idLocation),
                TO_CHAR(:NEW.id), 'Changed id of associated location', USER
            );
        END IF;

        IF UPDATING('firstName') AND (:OLD.firstName != :NEW.firstName) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Person', 'firstName',
                TO_CHAR(:OLD.firstName), TO_CHAR(:NEW.firstName),
                TO_CHAR(:NEW.id), 'Changed first name info', USER
            );
        END IF;

        IF UPDATING('middleName') AND (:OLD.middleName != :NEW.middleName) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Person', 'middleName',
                TO_CHAR(:OLD.middleName), TO_CHAR(:NEW.middleName),
                TO_CHAR(:NEW.id), 'Changed middle name info', USER
            );
        END IF;

        IF UPDATING('firstLastName') AND (:OLD.firstLastName != :NEW.firstLastName) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Person', 'firstLastName',
                TO_CHAR(:OLD.firstLastName), TO_CHAR(:NEW.firstLastName),
                TO_CHAR(:NEW.id), 'Changed first last name info', USER
            );
        END IF;

        IF UPDATING('secondLastName') AND (:OLD.secondLastName != :NEW.secondLastName) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Person', 'secondLastName',
                TO_CHAR(:OLD.secondLastName), TO_CHAR(:NEW.secondLastName),
                TO_CHAR(:NEW.id), 'Changed second last name info', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Person', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePerson;
/


CREATE OR REPLACE TRIGGER beforeSaveContactEmail
BEFORE INSERT OR UPDATE OR DELETE ON ContactEmail
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'ContactEmail', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('email') AND (:OLD.email != :NEW.email) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'ContactEmail', 'email',
                TO_CHAR(:OLD.email), TO_CHAR(:NEW.email),
                TO_CHAR(:NEW.id), 'Changed email address', USER
            );
        END IF;

        IF UPDATING('idPerson') AND (:OLD.idPerson != :NEW.idPerson) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'ContactEmail', 'idPerson',
                TO_CHAR(:OLD.idPerson), TO_CHAR(:NEW.idPerson),
                TO_CHAR(:NEW.id), 'Changed id of associated person', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'ContactEmail', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveContactEmail;
/


CREATE OR REPLACE TRIGGER beforeSaveContactNumber
BEFORE INSERT OR UPDATE OR DELETE ON ContactNumber
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'ContactNumber', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('phoneNumber') AND (:OLD.phoneNumber != :NEW.phoneNumber) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'ContactNumber', 'phoneNumber',
                TO_CHAR(:OLD.phoneNumber), TO_CHAR(:NEW.phoneNumber),
                TO_CHAR(:NEW.id), 'Changed phone number', USER
            );
        END IF;

        IF UPDATING('idPerson') AND (:OLD.idPerson != :NEW.idPerson) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'ContactNumber', 'idPerson',
                TO_CHAR(:OLD.idPerson), TO_CHAR(:NEW.idPerson),
                TO_CHAR(:NEW.id), 'Changed id of associated person', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'ContactNumber', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveContactNumber;
/


CREATE OR REPLACE TRIGGER beforeSaveCountry
BEFORE INSERT OR UPDATE OR DELETE ON Country
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Country', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Country', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed country name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Country', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveCountry;
/


CREATE OR REPLACE TRIGGER beforeSaveProvince
BEFORE INSERT OR UPDATE OR DELETE ON Province
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Province', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Province', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed province name', USER
            );
        END IF;

        IF UPDATING('idCountry') AND (:OLD.idCountry != :NEW.idCountry) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Province', 'idCountry',
                TO_CHAR(:OLD.idCountry), TO_CHAR(:NEW.idCountry),
                TO_CHAR(:NEW.id), 'Changed id of associated country', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Province', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveProvince;
/


CREATE OR REPLACE TRIGGER beforeSaveCanton
BEFORE INSERT OR UPDATE OR DELETE ON Canton
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Canton', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Canton', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed canton name', USER
            );
        END IF;

        IF UPDATING('idProvince') AND (:OLD.idProvince != :NEW.idProvince) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Canton', 'idProvince',
                TO_CHAR(:OLD.idProvince), TO_CHAR(:NEW.idProvince),
                TO_CHAR(:NEW.id), 'Changed id of associated province', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Canton', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveCanton;
/


CREATE OR REPLACE TRIGGER beforeSaveDistrict
BEFORE INSERT OR UPDATE OR DELETE ON District
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'District', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'District', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed district name', USER
            );
        END IF;

        IF UPDATING('idCanton') AND (:OLD.idCanton != :NEW.idCanton) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'District', 'idCanton',
                TO_CHAR(:OLD.idCanton), TO_CHAR(:NEW.idCanton),
                TO_CHAR(:NEW.id), 'Changed id of associated canton', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'District', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveDistrict;
/


CREATE OR REPLACE TRIGGER beforeSaveLocation
BEFORE INSERT OR UPDATE OR DELETE ON Location
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Location', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('address') AND (:OLD.address != :NEW.address) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Location', 'address',
                TO_CHAR(:OLD.address), TO_CHAR(:NEW.address),
                TO_CHAR(:NEW.id), 'Changed location address', USER
            );
        END IF;

        IF UPDATING('idDistrict') AND (:OLD.idDistrict != :NEW.idDistrict) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Location', 'idDistrict',
                TO_CHAR(:OLD.idDistrict), TO_CHAR(:NEW.idDistrict),
                TO_CHAR(:NEW.id), 'Changed id of associated district', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Location', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveLocation;
/

--======================================================================
--==== Triggers para tablas relacionadas a AnimalWelfareAssociation ====
--======================================================================

CREATE OR REPLACE TRIGGER beforeSaveDonationType
BEFORE INSERT OR UPDATE OR DELETE ON DonationType
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'DonationType', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'DonationType', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed donation type name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'DonationType', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveDonationType;
/


CREATE OR REPLACE TRIGGER beforeSaveCurrencyType
BEFORE INSERT OR UPDATE OR DELETE ON CurrencyType
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'CurrencyType', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'CurrencyType', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed currency type name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'CurrencyType', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveCurrencyType;
/


CREATE OR REPLACE TRIGGER beforeSaveAnimalWelfareAssociation
BEFORE INSERT OR UPDATE OR DELETE ON AnimalWelfareAssociation
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'AnimalWelfareAssociation', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'AnimalWelfareAssociation', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed animal welfare association name', USER
            );
        END IF;

        IF UPDATING('idLocation') AND (:OLD.idLocation != :NEW.idLocation) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'AnimalWelfareAssociation', 'idLocation',
                TO_CHAR(:OLD.idLocation), TO_CHAR(:NEW.idLocation),
                TO_CHAR(:NEW.id), 'Changed id of associated location', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'AnimalWelfareAssociation', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveAnimalWelfareAssociation;
/


CREATE OR REPLACE TRIGGER beforeSaveDonationDetail
BEFORE INSERT OR UPDATE OR DELETE ON DonationDetail
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'DonationDetail', NULL, NULL, NULL,
            TO_CHAR(:NEW.idAnimalWelfareAssociation) || '-' || TO_CHAR(:NEW.idDonation),
            'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('amount') AND (:OLD.amount != :NEW.amount) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'DonationDetail', 'amount',
                TO_CHAR(:OLD.amount), TO_CHAR(:NEW.amount),
                TO_CHAR(:NEW.idAnimalWelfareAssociation) || '-' || TO_CHAR(:NEW.idDonation),
                'Changed donation amount', USER
            );
        END IF;

        IF UPDATING('percentage') AND (:OLD.percentage != :NEW.percentage) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'DonationDetail', 'percentage',
                TO_CHAR(:OLD.percentage), TO_CHAR(:NEW.percentage),
                TO_CHAR(:NEW.idAnimalWelfareAssociation) || '-' || TO_CHAR(:NEW.idDonation),
                'Changed donation percentage', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'DonationDetail', NULL, NULL, NULL,
            TO_CHAR(:OLD.idAnimalWelfareAssociation) || '-' || TO_CHAR(:OLD.idDonation),
            'Tuple deletion', USER
        );
    END IF;
END beforeSaveDonationDetail;
/


CREATE OR REPLACE TRIGGER beforeSaveDonation
BEFORE INSERT OR UPDATE OR DELETE ON Donation
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Donation', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;
    
    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idPerson') AND (:OLD.idPerson != :NEW.idPerson) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Donation', 'idPerson',
                TO_CHAR(:OLD.idPerson), TO_CHAR(:NEW.idPerson),
                TO_CHAR(:NEW.id), 'Changed id of associated person', USER
            );
        END IF;

        IF UPDATING('idDonationType') AND (:OLD.idDonationType != :NEW.idDonationType) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Donation', 'idDonationType',
                TO_CHAR(:OLD.idDonationType), TO_CHAR(:NEW.idDonationType),
                TO_CHAR(:NEW.id), 'Changed id of associated donation type', USER
            );
        END IF;

        IF UPDATING('idCurrencyType') AND (:OLD.idCurrencyType != :NEW.idCurrencyType) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Donation', 'idCurrencyType',
                TO_CHAR(:OLD.idCurrencyType), TO_CHAR(:NEW.idCurrencyType),
                TO_CHAR(:NEW.id), 'Changed id of associated currency type', USER
            );
        END IF;

        IF UPDATING('idReward') AND (:OLD.idReward != :NEW.idReward) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Donation', 'idReward',
                TO_CHAR(:OLD.idReward), TO_CHAR(:NEW.idReward),
                TO_CHAR(:NEW.id), 'Changed id of associated reward', USER
            );
        END IF;

        IF UPDATING('donationDate') AND (:OLD.donationDate != :NEW.donationDate) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Donation', 'donationDate',
                TO_CHAR(:OLD.donationDate), TO_CHAR(:NEW.donationDate),
                TO_CHAR(:NEW.id), 'Changed donation date', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Donation', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveDonation;
/

--===================================================
--==== Triggers tablas usadas para el FosterHome ====
--===================================================

CREATE OR REPLACE TRIGGER beforeSaveFosterHomeStatus
BEFORE INSERT OR UPDATE OR DELETE ON FosterHomeStatus
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'FosterHomeStatus', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'FosterHomeStatus', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed foster home status name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'FosterHomeStatus', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveFosterHomeStatus;
/


CREATE OR REPLACE TRIGGER beforeSaveFosterHome
BEFORE INSERT OR UPDATE OR DELETE ON FosterHome
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'FosterHome', NULL, NULL, NULL,
            TO_CHAR(:NEW.idFosterHome), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idLocation') AND (:OLD.idLocation != :NEW.idLocation) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'FosterHome', 'idLocation',
                TO_CHAR(:OLD.idLocation), TO_CHAR(:NEW.idLocation),
                TO_CHAR(:NEW.idFosterHome), 'Changed associated location', USER
            );
        END IF;

        IF UPDATING('idFosterHomeStatus') AND (:OLD.idFosterHomeStatus != :NEW.idFosterHomeStatus) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'FosterHome', 'idFosterHomeStatus',
                TO_CHAR(:OLD.idFosterHomeStatus), TO_CHAR(:NEW.idFosterHomeStatus),
                TO_CHAR(:NEW.idFosterHome), 'Changed status of foster home', USER
            );
        END IF;

        IF UPDATING('maxCapacity') AND (:OLD.maxCapacity != :NEW.maxCapacity) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'FosterHome', 'maxCapacity',
                TO_CHAR(:OLD.maxCapacity), TO_CHAR(:NEW.maxCapacity),
                TO_CHAR(:NEW.idFosterHome), 'Changed max capacity', USER
            );
        END IF;

        IF UPDATING('requiresFoodDonation') AND (:OLD.requiresFoodDonation != :NEW.requiresFoodDonation) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'FosterHome', 'requiresFoodDonation',
                TO_CHAR(:OLD.requiresFoodDonation), TO_CHAR(:NEW.requiresFoodDonation),
                TO_CHAR(:NEW.idFosterHome), 'Changed food donation requirement', USER
            );
        END IF;

        IF UPDATING('petCount') AND (:OLD.petCount != :NEW.petCount) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'FosterHome', 'petCount',
                TO_CHAR(:OLD.petCount), TO_CHAR(:NEW.petCount),
                TO_CHAR(:NEW.idFosterHome), 'Changed current pet count', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'FosterHome', NULL, NULL, NULL,
            TO_CHAR(:OLD.idFosterHome), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveFosterHome;
/


CREATE OR REPLACE TRIGGER beforeSaveFosterHomeXPetSize
BEFORE INSERT OR UPDATE OR DELETE ON FosterHome_x_petSize
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'FosterHome_x_petSize', NULL, NULL, NULL,
            TO_CHAR(:NEW.idFosterHome) || '-' || TO_CHAR(:NEW.idPetSize),
            'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'FosterHome_x_petSize', NULL, NULL, NULL,
            TO_CHAR(:OLD.idFosterHome) || '-' || TO_CHAR(:OLD.idPetSize),
            'Tuple deletion', USER
        );
    END IF;
END beforeSaveFosterHomeXPetSize;
/


CREATE OR REPLACE TRIGGER beforeSaveFosterHomeXPetType
BEFORE INSERT OR UPDATE OR DELETE ON FosterHome_x_petType
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'FosterHome_x_petType', NULL, NULL, NULL,
            TO_CHAR(:NEW.idFosterHome) || '-' || TO_CHAR(:NEW.idPetType),
            'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'FosterHome_x_petType', NULL, NULL, NULL,
            TO_CHAR(:OLD.idFosterHome) || '-' || TO_CHAR(:OLD.idPetType),
            'Tuple deletion', USER
        );
    END IF;
END beforeSaveFosterHomeXPetType;
/

--================================================
-- Triggers tablas House, Adopter y adoption
--================================================

CREATE OR REPLACE TRIGGER beforeSaveHouseType
BEFORE INSERT OR UPDATE OR DELETE ON HouseType
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'HouseType', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'HouseType', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed house type name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'HouseType', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveHouseType;
/


CREATE OR REPLACE TRIGGER beforeSaveHouse
BEFORE INSERT OR UPDATE OR DELETE ON House
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'House', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idHouseType') AND (:OLD.idHouseType != :NEW.idHouseType) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'House', 'idHouseType',
                TO_CHAR(:OLD.idHouseType), TO_CHAR(:NEW.idHouseType),
                TO_CHAR(:NEW.id), 'Changed associated house type', USER
            );
        END IF;

        IF UPDATING('hasYard') AND (:OLD.hasYard != :NEW.hasYard) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'House', 'hasYard',
                TO_CHAR(:OLD.hasYard), TO_CHAR(:NEW.hasYard),
                TO_CHAR(:NEW.id), 'Changed yard availability flag', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'House', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveHouse;
/


CREATE OR REPLACE TRIGGER beforeSaveExerciseTime
BEFORE INSERT OR UPDATE OR DELETE ON ExerciseTime
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'ExerciseTime', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('value') AND (:OLD.value != :NEW.value) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'ExerciseTime', 'value',
                TO_CHAR(:OLD.value), TO_CHAR(:NEW.value),
                TO_CHAR(:NEW.id), 'Changed exercise time value', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'ExerciseTime', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveExerciseTime;
/


CREATE OR REPLACE TRIGGER beforeSaveAdopter
BEFORE INSERT OR UPDATE OR DELETE ON Adopter
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Adopter', NULL, NULL, NULL,
            TO_CHAR(:NEW.idAdopter), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idHouse') AND (:OLD.idHouse != :NEW.idHouse) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Adopter', 'idHouse',
                TO_CHAR(:OLD.idHouse), TO_CHAR(:NEW.idHouse),
                TO_CHAR(:NEW.idAdopter), 'Changed associated house', USER
            );
        END IF;

        IF UPDATING('idExerciseTime') AND (:OLD.idExerciseTime != :NEW.idExerciseTime) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Adopter', 'idExerciseTime',
                TO_CHAR(:OLD.idExerciseTime), TO_CHAR(:NEW.idExerciseTime),
                TO_CHAR(:NEW.idAdopter), 'Changed exercise time', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Adopter', NULL, NULL, NULL,
            TO_CHAR(:OLD.idAdopter), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveAdopter;
/


CREATE OR REPLACE TRIGGER beforeSaveOtherPet
BEFORE INSERT OR UPDATE OR DELETE ON OtherPet
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'OtherPet', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idPetBreed') AND (:OLD.idPetBreed != :NEW.idPetBreed) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'OtherPet', 'idPetBreed',
                TO_CHAR(:OLD.idPetBreed), TO_CHAR(:NEW.idPetBreed),
                TO_CHAR(:NEW.id), 'Changed associated pet breed', USER
            );
        END IF;

        IF UPDATING('idAdopter') AND (:OLD.idAdopter != :NEW.idAdopter) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'OtherPet', 'idAdopter',
                TO_CHAR(:OLD.idAdopter), TO_CHAR(:NEW.idAdopter),
                TO_CHAR(:NEW.id), 'Changed associated adopter', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'OtherPet', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveOtherPet;
/


CREATE OR REPLACE TRIGGER beforeSaveAdoption
BEFORE INSERT OR UPDATE OR DELETE ON Adoption
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Adoption', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idPerson') AND (:OLD.idPerson != :NEW.idPerson) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Adoption', 'idPerson',
                TO_CHAR(:OLD.idPerson), TO_CHAR(:NEW.idPerson),
                TO_CHAR(:NEW.id), 'Changed associated person', USER
            );
        END IF;

        IF UPDATING('idAdopter') AND (:OLD.idAdopter != :NEW.idAdopter) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Adoption', 'idAdopter',
                TO_CHAR(:OLD.idAdopter), TO_CHAR(:NEW.idAdopter),
                TO_CHAR(:NEW.id), 'Changed associated adopter', USER
            );
        END IF;

        IF UPDATING('idPet') AND (:OLD.idPet != :NEW.idPet) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Adoption', 'idPet',
                TO_CHAR(:OLD.idPet), TO_CHAR(:NEW.idPet),
                TO_CHAR(:NEW.id), 'Changed associated pet', USER
            );
        END IF;

        IF UPDATING('adoptionDate') AND (:OLD.adoptionDate != :NEW.adoptionDate) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Adoption', 'adoptionDate',
                TO_CHAR(:OLD.adoptionDate), TO_CHAR(:NEW.adoptionDate),
                TO_CHAR(:NEW.id), 'Changed adoption date', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Adoption', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveAdoption;
/


CREATE OR REPLACE TRIGGER beforeSaveFollowUp
BEFORE INSERT OR UPDATE OR DELETE ON FollowUp
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'FollowUp', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idAdoption') AND (:OLD.idAdoption != :NEW.idAdoption) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'FollowUp', 'idAdoption',
                TO_CHAR(:OLD.idAdoption), TO_CHAR(:NEW.idAdoption),
                TO_CHAR(:NEW.id), 'Changed associated adoption', USER
            );
        END IF;

        IF UPDATING('comments') AND (:OLD.comments != :NEW.comments) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'FollowUp', 'comments',
                TO_CHAR(:OLD.comments), TO_CHAR(:NEW.comments),
                TO_CHAR(:NEW.id), 'Changed comments', USER
            );
        END IF;

        IF UPDATING('followUpDate') AND (:OLD.followUpDate != :NEW.followUpDate) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'FollowUp', 'followUpDate',
                TO_CHAR(:OLD.followUpDate), TO_CHAR(:NEW.followUpDate),
                TO_CHAR(:NEW.id), 'Changed follow-up date', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'FollowUp', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveFollowUp;
/


CREATE OR REPLACE TRIGGER beforeSavePetOwnerRating
BEFORE INSERT OR UPDATE OR DELETE ON PetOwnerRating
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetOwnerRating', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idAdoption') AND (:OLD.idAdoption != :NEW.idAdoption) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetOwnerRating', 'idAdoption',
                TO_CHAR(:OLD.idAdoption), TO_CHAR(:NEW.idAdoption),
                TO_CHAR(:NEW.id), 'Changed associated adoption', USER
            );
        END IF;

        IF UPDATING('rating') AND (:OLD.rating != :NEW.rating) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetOwnerRating', 'rating',
                TO_CHAR(:OLD.rating), TO_CHAR(:NEW.rating),
                TO_CHAR(:NEW.id), 'Changed rating score', USER
            );
        END IF;

        IF UPDATING('notes') AND (:OLD.notes != :NEW.notes) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetOwnerRating', 'notes',
                TO_CHAR(:OLD.notes), TO_CHAR(:NEW.notes),
                TO_CHAR(:NEW.id), 'Changed rating notes', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetOwnerRating', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePetOwnerRating;
/

--================================================
--==== Triggers tablas relacionadas a Photo ====
--================================================

CREATE OR REPLACE TRIGGER beforeSavePhotoType
BEFORE INSERT OR UPDATE OR DELETE ON PhotoType
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PhotoType', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PhotoType', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed photo type name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PhotoType', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePhotoType;
/


CREATE OR REPLACE TRIGGER beforeSavePhoto
BEFORE INSERT OR UPDATE OR DELETE ON Photo
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Photo', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idFollowUp') AND (:OLD.idFollowUp != :NEW.idFollowUp) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Photo', 'idFollowUp',
                TO_CHAR(:OLD.idFollowUp), TO_CHAR(:NEW.idFollowUp),
                TO_CHAR(:NEW.id), 'Changed associated follow-up', USER
            );
        END IF;

        IF UPDATING('idPet') AND (:OLD.idPet != :NEW.idPet) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Photo', 'idPet',
                TO_CHAR(:OLD.idPet), TO_CHAR(:NEW.idPet),
                TO_CHAR(:NEW.id), 'Changed associated pet', USER
            );
        END IF;

        IF UPDATING('idPhotoType') AND (:OLD.idPhotoType != :NEW.idPhotoType) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Photo', 'idPhotoType',
                TO_CHAR(:OLD.idPhotoType), TO_CHAR(:NEW.idPhotoType),
                TO_CHAR(:NEW.id), 'Changed associated photo type', USER
            );
        END IF;

        IF UPDATING('photoURL') AND (:OLD.photoURL != :NEW.photoURL) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Photo', 'photoURL',
                TO_CHAR(:OLD.photoURL), TO_CHAR(:NEW.photoURL),
                TO_CHAR(:NEW.id), 'Changed photo URL', USER
            );
        END IF;

        IF UPDATING('uploadDate') AND (:OLD.uploadDate != :NEW.uploadDate) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Photo', 'uploadDate',
                TO_CHAR(:OLD.uploadDate), TO_CHAR(:NEW.uploadDate),
                TO_CHAR(:NEW.id), 'Changed photo upload date', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Photo', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePhoto;
/

--=======================================================
--==== Triggers tablas de enfermedades y veterinario ====       
--=======================================================

CREATE OR REPLACE TRIGGER beforeSaveVeterinarian
BEFORE INSERT OR UPDATE OR DELETE ON Veterinarian
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Veterinarian', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idPerson') AND (:OLD.idPerson != :NEW.idPerson) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Veterinarian', 'idPerson',
                TO_CHAR(:OLD.idPerson), TO_CHAR(:NEW.idPerson),
                TO_CHAR(:NEW.id), 'Changed associated person', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Veterinarian', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveVeterinarian;
/


CREATE OR REPLACE TRIGGER beforeSaveDisease
BEFORE INSERT OR UPDATE OR DELETE ON Disease
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Disease', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Disease', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed disease name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Disease', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveDisease;
/


CREATE OR REPLACE TRIGGER beforeSaveDiseaseXPet
BEFORE INSERT OR UPDATE OR DELETE ON Disease_x_pet
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Disease_x_pet', NULL, NULL, NULL,
            TO_CHAR(:NEW.idDisease) || '-' || TO_CHAR(:NEW.idPet),
            'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Disease_x_pet', NULL, NULL, NULL,
            TO_CHAR(:OLD.idDisease) || '-' || TO_CHAR(:OLD.idPet),
            'Tuple deletion', USER
        );
    END IF;
END beforeSaveDiseaseXPet;
/


CREATE OR REPLACE TRIGGER beforeSaveTreatment
BEFORE INSERT OR UPDATE OR DELETE ON Treatment
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Treatment', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Treatment', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed treatment name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Treatment', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveTreatment;
/


CREATE OR REPLACE TRIGGER beforeSaveTreatmentXDisease
BEFORE INSERT OR UPDATE OR DELETE ON Treatment_x_disease
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Treatment_x_disease', NULL, NULL, NULL,
            TO_CHAR(:NEW.idDisease) || '-' || TO_CHAR(:NEW.idTreatment),
            'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('timeLength') AND (:OLD.timeLength != :NEW.timeLength) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Treatment_x_disease', 'timeLength',
                TO_CHAR(:OLD.timeLength), TO_CHAR(:NEW.timeLength),
                TO_CHAR(:NEW.idDisease) || '-' || TO_CHAR(:NEW.idTreatment),
                'Changed treatment time length', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Treatment_x_disease', NULL, NULL, NULL,
            TO_CHAR(:OLD.idDisease) || '-' || TO_CHAR(:OLD.idTreatment),
            'Tuple deletion', USER
        );
    END IF;
END beforeSaveTreatmentXDisease;
/


CREATE OR REPLACE TRIGGER beforeSaveMedication
BEFORE INSERT OR UPDATE OR DELETE ON Medication
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Medication', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Medication', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed medication name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Medication', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveMedication;
/


CREATE OR REPLACE TRIGGER beforeSaveMedicationXTreatment
BEFORE INSERT OR UPDATE OR DELETE ON Medication_x_treatment
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Medication_x_treatment', NULL, NULL, NULL,
            TO_CHAR(:NEW.idMedication) || '-' || TO_CHAR(:NEW.idTreatment),
            'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('dosage') AND (:OLD.dosage != :NEW.dosage) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Medication_x_treatment', 'dosage',
                TO_CHAR(:OLD.dosage), TO_CHAR(:NEW.dosage),
                TO_CHAR(:NEW.idMedication) || '-' || TO_CHAR(:NEW.idTreatment),
                'Changed medication dosage', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Medication_x_treatment', NULL, NULL, NULL,
            TO_CHAR(:OLD.idMedication) || '-' || TO_CHAR(:OLD.idTreatment),
            'Tuple deletion', USER
        );
    END IF;
END beforeSaveMedicationXTreatment;
/

--================================================
--==== Triggers tablas Pet ====                
--================================================

CREATE OR REPLACE TRIGGER beforeSavePetType
BEFORE INSERT OR UPDATE OR DELETE ON PetType
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetType', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetType', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed pet type name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetType', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePetType;
/


CREATE OR REPLACE TRIGGER beforeSavePetBreed
BEFORE INSERT OR UPDATE OR DELETE ON PetBreed
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetBreed', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetBreed', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed breed name', USER
            );
        END IF;

        IF UPDATING('idPetType') AND (:OLD.idPetType != :NEW.idPetType) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetBreed', 'idPetType',
                TO_CHAR(:OLD.idPetType), TO_CHAR(:NEW.idPetType),
                TO_CHAR(:NEW.id), 'Changed associated pet type', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetBreed', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePetBreed;
/


CREATE OR REPLACE TRIGGER beforeSavePetSize
BEFORE INSERT OR UPDATE OR DELETE ON PetSize
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetSize', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetSize', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed pet size name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetSize', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePetSize;
/


CREATE OR REPLACE TRIGGER beforeSavePetColor
BEFORE INSERT OR UPDATE OR DELETE ON PetColor
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetColor', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetColor', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed pet color name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetColor', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePetColor;
/


CREATE OR REPLACE TRIGGER beforeSavePetSeverity
BEFORE INSERT OR UPDATE OR DELETE ON PetSeverity
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetSeverity', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetSeverity', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed pet severity name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetSeverity', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePetSeverity;
/


CREATE OR REPLACE TRIGGER beforeSavePetEnergy
BEFORE INSERT OR UPDATE OR DELETE ON PetEnergy
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetEnergy', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetEnergy', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed pet energy name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetEnergy', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePetEnergy;
/


CREATE OR REPLACE TRIGGER beforeSavePetTrainability
BEFORE INSERT OR UPDATE OR DELETE ON PetTrainability
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetTrainability', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetTrainability', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed pet trainability name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetTrainability', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePetTrainability;
/


CREATE OR REPLACE TRIGGER beforeSavePetStatus
BEFORE INSERT OR UPDATE OR DELETE ON PetStatus
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetStatus', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'PetStatus', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed pet status name', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'PetStatus', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePetStatus;
/


CREATE OR REPLACE TRIGGER beforeSavePet
BEFORE INSERT OR UPDATE OR DELETE ON Pet
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Pet', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idLocation') AND (:OLD.idLocation != :NEW.idLocation) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'idLocation',
                TO_CHAR(:OLD.idLocation), TO_CHAR(:NEW.idLocation),
                TO_CHAR(:NEW.id), 'Changed pet location', USER
            );
        END IF;

        IF UPDATING('idPerson') AND (:OLD.idPerson != :NEW.idPerson) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'idPerson',
                TO_CHAR(:OLD.idPerson), TO_CHAR(:NEW.idPerson),
                TO_CHAR(:NEW.id), 'Changed associated person', USER
            );
        END IF;

        IF UPDATING('idPetBreed') AND (:OLD.idPetBreed != :NEW.idPetBreed) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'idPetBreed',
                TO_CHAR(:OLD.idPetBreed), TO_CHAR(:NEW.idPetBreed),
                TO_CHAR(:NEW.id), 'Changed breed', USER
            );
        END IF;

        IF UPDATING('idPetSize') AND (:OLD.idPetSize != :NEW.idPetSize) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'idPetSize',
                TO_CHAR(:OLD.idPetSize), TO_CHAR(:NEW.idPetSize),
                TO_CHAR(:NEW.id), 'Changed size', USER
            );
        END IF;

        IF UPDATING('idPetColor') AND (:OLD.idPetColor != :NEW.idPetColor) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'idPetColor',
                TO_CHAR(:OLD.idPetColor), TO_CHAR(:NEW.idPetColor),
                TO_CHAR(:NEW.id), 'Changed color', USER
            );
        END IF;

        IF UPDATING('idPetSeverity') AND (:OLD.idPetSeverity != :NEW.idPetSeverity) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'idPetSeverity',
                TO_CHAR(:OLD.idPetSeverity), TO_CHAR(:NEW.idPetSeverity),
                TO_CHAR(:NEW.id), 'Changed severity', USER
            );
        END IF;

        IF UPDATING('idPetEnergy') AND (:OLD.idPetEnergy != :NEW.idPetEnergy) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'idPetEnergy',
                TO_CHAR(:OLD.idPetEnergy), TO_CHAR(:NEW.idPetEnergy),
                TO_CHAR(:NEW.id), 'Changed energy level', USER
            );
        END IF;

        IF UPDATING('idPetTrainability') AND (:OLD.idPetTrainability != :NEW.idPetTrainability) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'idPetTrainability',
                TO_CHAR(:OLD.idPetTrainability), TO_CHAR(:NEW.idPetTrainability),
                TO_CHAR(:NEW.id), 'Changed trainability level', USER
            );
        END IF;

        IF UPDATING('idPetStatus') AND (:OLD.idPetStatus != :NEW.idPetStatus) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'idPetStatus',
                TO_CHAR(:OLD.idPetStatus), TO_CHAR(:NEW.idPetStatus),
                TO_CHAR(:NEW.id), 'Changed pet status', USER
            );
        END IF;

        IF UPDATING('idVeterinarian') AND (:OLD.idVeterinarian != :NEW.idVeterinarian) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'idVeterinarian',
                TO_CHAR(:OLD.idVeterinarian), TO_CHAR(:NEW.idVeterinarian),
                TO_CHAR(:NEW.id), 'Changed veterinarian', USER
            );
        END IF;

        IF UPDATING('chipId') AND (:OLD.chipId != :NEW.chipId) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'chipId',
                TO_CHAR(:OLD.chipId), TO_CHAR(:NEW.chipId),
                TO_CHAR(:NEW.id), 'Changed chip ID', USER
            );
        END IF;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed pet name', USER
            );
        END IF;

        IF UPDATING('requiresSpace') AND (:OLD.requiresSpace != :NEW.requiresSpace) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'requiresSpace',
                TO_CHAR(:OLD.requiresSpace), TO_CHAR(:NEW.requiresSpace),
                TO_CHAR(:NEW.id), 'Changed space requirement', USER
            );
        END IF;

        IF UPDATING('estimatedAge') AND (:OLD.estimatedAge != :NEW.estimatedAge) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Pet', 'estimatedAge',
                TO_CHAR(:OLD.estimatedAge), TO_CHAR(:NEW.estimatedAge),
                TO_CHAR(:NEW.id), 'Changed estimated age', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Pet', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSavePet;
/

--================================================
--==== Triggers recompensa y parametros ====
--================================================

CREATE OR REPLACE TRIGGER beforeSaveReward
BEFORE INSERT OR UPDATE OR DELETE ON Reward
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Reward', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('idPet') AND (:OLD.idPet != :NEW.idPet) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Reward', 'idPet',
                TO_CHAR(:OLD.idPet), TO_CHAR(:NEW.idPet),
                TO_CHAR(:NEW.id), 'Changed associated pet', USER
            );
        END IF;

        IF UPDATING('idCurrencyType') AND (:OLD.idCurrencyType != :NEW.idCurrencyType) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Reward', 'idCurrencyType',
                TO_CHAR(:OLD.idCurrencyType), TO_CHAR(:NEW.idCurrencyType),
                TO_CHAR(:NEW.id), 'Changed currency type', USER
            );
        END IF;

        IF UPDATING('amount') AND (:OLD.amount != :NEW.amount) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Reward', 'amount',
                TO_CHAR(:OLD.amount), TO_CHAR(:NEW.amount),
                TO_CHAR(:NEW.id), 'Changed reward amount', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Reward', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveReward;
/


CREATE OR REPLACE TRIGGER beforeSaveParameter
BEFORE INSERT OR UPDATE OR DELETE ON Parameter
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :new.creationDate := SYSDATE;
        :new.createdBy := USER;

        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Parameter', NULL, NULL, NULL,
            TO_CHAR(:NEW.id), 'New tuple insertion', USER
        );
    END IF;

    IF UPDATING THEN
        :new.updatedDate := SYSDATE;
        :new.updatedBy := USER;

        IF UPDATING('description') AND (:OLD.description != :NEW.description) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Parameter', 'description',
                TO_CHAR(:OLD.description), TO_CHAR(:NEW.description),
                TO_CHAR(:NEW.id), 'Changed parameter description', USER
            );
        END IF;

        IF UPDATING('name') AND (:OLD.name != :NEW.name) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Parameter', 'name',
                TO_CHAR(:OLD.name), TO_CHAR(:NEW.name),
                TO_CHAR(:NEW.id), 'Changed parameter name', USER
            );
        END IF;

        IF UPDATING('textValue') AND (:OLD.textValue != :NEW.textValue) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Parameter', 'textValue',
                TO_CHAR(:OLD.textValue), TO_CHAR(:NEW.textValue),
                TO_CHAR(:NEW.id), 'Changed parameter text value', USER
            );
        END IF;

        IF UPDATING('numberValue') AND (:OLD.numberValue != :NEW.numberValue) THEN
            ADOPCION_AUDIT.createLog(
                'ADOPCION_APP', 'Parameter', 'value',
                TO_CHAR(:OLD.numberValue), TO_CHAR(:NEW.numberValue),
                TO_CHAR(:NEW.id), 'Changed parameter number value', USER
            );
        END IF;
    END IF;

    IF DELETING THEN
        ADOPCION_AUDIT.createLog(
            'ADOPCION_APP', 'Parameter', NULL, NULL, NULL,
            TO_CHAR(:OLD.id), 'Tuple deletion', USER
        );
    END IF;
END beforeSaveParameter;
/

