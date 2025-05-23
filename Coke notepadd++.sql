
--Obss för delete--
/*-- BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE överföring CASCADE CONSTRAINTS PURGE';
   EXECUTE IMMEDIATE 'DROP TABLE insättning CASCADE CONSTRAINTS PURGE';
   EXECUTE IMMEDIATE 'DROP TABLE uttag CASCADE CONSTRAINTS PURGE';
   EXECUTE IMMEDIATE 'DROP TABLE kontoägare CASCADE CONSTRAINTS PURGE';
   EXECUTE IMMEDIATE 'DROP TABLE konto CASCADE CONSTRAINTS PURGE';
   EXECUTE IMMEDIATE 'DROP TABLE ränteändring CASCADE CONSTRAINTS PURGE';
   EXECUTE IMMEDIATE 'DROP TABLE kontotyp CASCADE CONSTRAINTS PURGE';
   EXECUTE IMMEDIATE 'DROP TABLE bankkund CASCADE CONSTRAINTS PURGE';
END;
/
--*/


-- Skapar table för bankkund--
CREATE TABLE bankkund (
    PNR VARCHAR2(11) NOT NULL,
    FNAMN VARCHAR2(25) NOT NULL,
    ENAMN VARCHAR2(25) NOT NULL,
    PASSWD VARCHAR2(16) NOT NULL
);

-- Lägger till constraint och primary key --
ALTER TABLE bankkund ADD CONSTRAINT PK_bankkund PRIMARY KEY (PNR);

-- Test/verifierring --
SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name = 'BANKKUND';


-- Skapar table för bankkund--
CREATE TABLE kontotyp (
    KTNR NUMBER(6) NOT NULL,
    KTNAMN VARCHAR2(20) NOT NULL,
    RÄNTA NUMBER(5,2) NOT NULL
);

-- Lägger till constraint och primary key --
ALTER TABLE kontotyp ADD CONSTRAINT PK_kontotyp PRIMARY KEY (KTNR);

-- Test/verifierring --
SELECT * from kontotyp;
DESC kontotyp;
SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name = 'KONTOTYP';

-- Skapar table för ränteändring--
CREATE TABLE ränteändring (
    RNR NUMBER(6) NOT NULL,
    KTNR NUMBER(6) NOT NULL,
    RÄNTA NUMBER(5,2) NOT NULL,
    RNR_DATUM DATE NOT NULL
);

-- Lägger till constraint och primary key --
ALTER TABLE ränteändring ADD CONSTRAINT PK_ränteändring PRIMARY KEY (RNR);

-- Lägger till constraint och foreign key --
ALTER TABLE ränteändring 
    ADD CONSTRAINT FK_ränteändring_kontotyp FOREIGN KEY (KTNR) REFERENCES kontotyp(KTNR);
	


-- Test/verifierring --
SELECT * from ränteändring;
DESC ränteändring;
SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name = 'RÄNTEÄNDRING';

-- Skapar table för konto--
CREATE TABLE konto (
    KNR NUMBER(8) NOT NULL,
    KTNR NUMBER(6) NOT NULL,
    REGDATUM DATE NOT NULL,
    SALDO NUMBER(10,2)
);

-- Lägger till constraint och primary key --
ALTER TABLE konto ADD CONSTRAINT PK_konto PRIMARY KEY (KNR);

-- Lägger till constraint och foreign key --
ALTER TABLE konto 
    ADD CONSTRAINT FK_konto_kontotyp FOREIGN KEY (KTNR) REFERENCES kontotyp(KTNR);


-- Test/verifierring --
SELECT * from konto;
DESC ränteändring;
SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name = 'KONTO';




-- Skapar table för kontoägare--
CREATE TABLE kontoägare (
    RADNR NUMBER(9) NOT NULL,
    PNR VARCHAR2(11) NOT NULL,
    KNR NUMBER(8) NOT NULL
);

-- Lägger till constraint och primary key --
ALTER TABLE kontoägare ADD CONSTRAINT PK_kontoägare PRIMARY KEY (RADNR);

-- Lägger till constraint och foreign key --
ALTER TABLE kontoägare 
    ADD CONSTRAINT FK_kontoägare_kund 
    FOREIGN KEY (PNR) REFERENCES BANKKUND(PNR);

ALTER TABLE kontoägare 
    ADD CONSTRAINT FK_kontoägare_konto 
    FOREIGN KEY (KNR) REFERENCES KONTO(KNR);


-- Test/verifierring --
SELECT * from kontoägare;
DESC ränteändring;
SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name = 'KONTOÄGARE';




-- Skapar table för uttag--
CREATE TABLE uttag (
    RADNR  NUMBER(9) NOT NULL,
    PNR    VARCHAR2(11) NOT NULL,
    KNR    NUMBER(8) NOT NULL,
    BELOPP NUMBER(10, 2),
    DATUM  DATE NOT NULL
);

-- Lägger till constraint och primary key --
ALTER TABLE uttag ADD CONSTRAINT PK_uttag PRIMARY KEY (RADNR);

-- Lägger till constraint och foreign key --
ALTER TABLE uttag 
    ADD CONSTRAINT FK_uttag_kund FOREIGN KEY (PNR) REFERENCES bankkund(PNR);
ALTER TABLE uttag 
    ADD CONSTRAINT FK_uttag_konto FOREIGN KEY (KNR) REFERENCES konto(KNR);
	
	
	
	
-- Test/verifierring --
SELECT * from uttag;
DESC uttag;
SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name = 'UTTAG';





-- Skapar table för insättning--

CREATE TABLE insättning (
    RADNR  NUMBER(9) NOT NULL,
    PNR    VARCHAR2(11) NOT NULL,
    KNR    NUMBER(8) NOT NULL,
    BELOPP NUMBER(10, 2),
    DATUM  DATE NOT NULL
);

-- Lägger till constraint och primary key --
ALTER TABLE insättning ADD CONSTRAINT PK_insättning PRIMARY KEY ( RADNR );

-- Lägger till constraint och foreign key --
ALTER TABLE insättning
    ADD CONSTRAINT FK_insättning_kund FOREIGN KEY ( PNR )
        REFERENCES BANKKUND ( PNR );

ALTER TABLE insättning
    ADD CONSTRAINT FK_insättning_konto FOREIGN KEY ( KNR )
        REFERENCES KONTO ( KNR );
		

	
-- Test/verifierring --
		
SELECT * from insättning;
DESC insättning;
SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name = 'INSÄTTNING';








-- Skapar table för överföring--
CREATE TABLE överföring (
    RADNR NUMBER(9) NOT NULL,
    PNR VARCHAR2(11) NOT NULL,
    FRÅN_KNR NUMBER(8) NOT NULL,
    TILL_KNR NUMBER(8) NOT NULL,
    BELOPP NUMBER(10,2),
    DATUM DATE NOT NULL
);

-- Lägger till constraint och primary key --
ALTER TABLE överföring ADD CONSTRAINT PK_överföring PRIMARY KEY (RADNR);



-- Lägger till constraint och foreign key --
ALTER TABLE överföring 
    ADD CONSTRAINT FK_överföring_kund FOREIGN KEY (PNR) REFERENCES bankkund(PNR);
ALTER TABLE överföring
    ADD CONSTRAINT FK_överföring_från FOREIGN KEY (FRÅN_KNR) REFERENCES konto(KNR);
ALTER TABLE överföring
    ADD CONSTRAINT FK_överföring_till FOREIGN KEY (TILL_KNR) REFERENCES konto(KNR);



-- Test/verifierring --
SELECT * from överföring;
DESC överföring;
SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name = 'ÖVERFÖRING';




--------------------------------------------------------------
--uppgift 3--

CREATE OR REPLACE TRIGGER biufer_bankkund
BEFORE INSERT OR UPDATE ON bankkund
FOR EACH ROW
WHEN (length(new.passwd) <> 6)
BEGIN  
    RAISE_APPLICATION_ERROR(-20001, 'Ditt lösenord måste vara exakt 6 tecken långt.');
END;
/


-- Test/verifierring --
SELECT *
FROM user_triggers
WHERE trigger_name = 'BIUFER_BANKKUND';


-- ORA-20001: Lösenordet måste vara exakt 6 tecken långt. Lång-- 
insert into bankkund(pnr, fnamn, enamn, passwd)
VALUES('900101-0101', 'HTML', 'CSS', 'javascript')

--ORA-20001: Lösenordet måste vara exakt 6 tecken långt. Kort --
insert into bankkund(pnr, fnamn, enamn, passwd)
VALUES('890101-0101', 'Responsive', 'Design', 'react')
---------------------------------------

--1 row inserted.--
insert into bankkund(pnr, fnamn, enamn, passwd)
VALUES('880101-0101', 'MY', 'SQL', 'oracle')
---------------------------------------

--test-
select * from BANKKUND;

-- tabort inmattade data from bakkund--

DELETE FROM BANKKUND WHERE fnamn='MY';

----------------------------------------------------

-- uppgift 4 ---



-- Här skapas eller ersättas proceduren "do_bankkund". Den används för att lägga till nya kunder i tabellen "bankkund"

CREATE OR REPLACE PROCEDURE do_bankkund (
    -- Inparametrar:
    p_pnr    IN bankkund.pnr%TYPE,     -- Personnummer
    p_fnamn  IN bankkund.fnamn%TYPE,   -- Förnamn
    p_enamn  IN bankkund.enamn%TYPE,   -- Efternamn
    p_passwd IN bankkund.passwd%TYPE   -- Lösenord
)
IS

BEGIN
    -- Lägger till en ny rad i tabellen bankkund med värden från inparametrarna
    INSERT INTO bankkund (pnr, fnamn, enamn, passwd)
    VALUES (p_pnr, p_fnamn, p_enamn, p_passwd);
END;
/

/*Jag skapar en procedur som heter do_bankkund.
Den tar emot fyra värden: personnummer, förnamn, efternamn och lösenord. 
När jag anropar proceduren, körs en INSERT som lägger in en ny kund i tabellen bankkund med de värdena jag skickar in.*/

-- Test/verifierring --

/*Jag testar att anropa proceduren med värdena '870101-0101', 'Data', 'Bas', och 'höst24'. 
Det gör att en ny rad skapas i databasen för kunden. 
Jag kör en SELECT från tabellen bankkund för att kontrollera att kunden verkligen har lagts till.
Sist tester jag om om min procedur do_bankkund finns*/

BEGIN
    do_bankkund('870101-0101', 'Data', 'Bas', 'höst24');
	commit;
END;
/

select * 
from bankkund;

SELECT object_name, status
FROM user_objects
WHERE object_type = 'PROCEDURE'
AND object_name = 'DO_BANKKUND';


----------------------------


-- uppgift 5---

/* Triggertest med nedan insert men den funger inte då lösenordet är mindre än 6 ord. 
Får fel meddelandet ERROR at line 1:
ORA-20001: Lösenordet måste vara exakt 6 tecken långt.
ORA-06512: at "SQL_DC0EVZB8UCJV124OU9JVZHDXEL.BIUFER_BANKKUND", line 5
ORA-04088: error during execution of trigger 'SQL_DC0EVZB8UCJV124OU9JVZHDXEL.BIUFER_BANKKUND'
ORA-06512: at "SQL_DC0EVZB8UCJV124OU9JVZHDXEL.DO_BANKKUND", line 12
ORA-06512: at line 1.*/

Triggertest  =   begin do_bankkund('691124-4478','Bo','Ek','qwe'); end; 

-- Jag klasterar in nedan inster kunder och dem fungerar då dem uppfyller kriterierna--

BEGIN
do_bankkund('540126-1111','Hans','Rosendahl','olle45');
do_bankkund('560126-1111','Hans','Rosengårdh','olle85');
do_bankkund('540126-1457','Lina','Karlsson','asdfgh');
do_bankkund('691124-4478','Leena','Kvist','qwerty');
COMMIT;
END;
/

-- Jag tester med ---

select *
from bankkund;

-------------------------------

-- uppgift 6--

-- Jag skapar en sekvens med namnet radnr_seq. Denna används till att skapa primärnyckelvärden för alla kolumner med namnet radnr. --

CREATE SEQUENCE radnr_seq
    START WITH 1     
    INCREMENT BY 1;

-- Test--

SELECT sequence_name
FROM user_sequences
WHERE sequence_name = 'RADNR_SEQ';


-- Lägger nu till rader i tabellerna kontotyp, konto och kontoägare genom att kopiera och klistra in nedanstående i SQL Developer.-- 

INSERT INTO kontotyp(ktnr,ktnamn,ränta)
VALUES(1,'bondkonto',3.4);
INSERT INTO kontotyp(ktnr,ktnamn,ränta)
VALUES(2,'potatiskonto',4.4);
INSERT INTO kontotyp(ktnr,ktnamn,ränta)
VALUES(3,'griskonto',2.4);
COMMIT;
INSERT INTO konto(knr,ktnr,regdatum,saldo)
VALUES(123,1,SYSDATE - 321,0);
INSERT INTO konto(knr,ktnr,regdatum,saldo)
VALUES(5899,2,SYSDATE - 2546,0);
INSERT INTO konto(knr,ktnr,regdatum,saldo)
VALUES(5587,3,SYSDATE - 10,0);
INSERT INTO konto(knr,ktnr,regdatum,saldo)
VALUES(8896,1,SYSDATE - 45,0);
COMMIT;
INSERT INTO kontoägare(radnr,pnr,knr)
VALUES(radnr_seq.NEXTVAL,'540126-1111',123);
INSERT INTO kontoägare(radnr,pnr,knr)
VALUES(radnr_seq.NEXTVAL,'691124-4478',123);
INSERT INTO kontoägare(radnr,pnr,knr)
VALUES(radnr_seq.NEXTVAL,'540126-1111',5899);
INSERT INTO kontoägare(radnr,pnr,knr)
VALUES(radnr_seq.NEXTVAL,'691124-4478',8896);
COMMIT;



-- Jag tester med ---

select *
from kontotyp;


select *
from kontoägare;


select *
from konto;

-- och även med hjälp av join kan jag testa samtliga tabellerna--

SELECT 
    bk.fnamn || ' ' || bk.enamn AS namn,
    ka.pnr,
    k.knr AS kontonummer,
    k.regdatum,
    k.saldo,
    kt.ktnr,
    kt.ktnamn,
    kt.ränta
FROM konto k
LEFT JOIN kontoägare ka ON k.knr = ka.knr
LEFT JOIN bankkund bk ON ka.pnr = bk.pnr
JOIN kontotyp kt ON k.ktnr = kt.ktnr
ORDER BY k.knr;
/* Visar alla konton i banken, oavsett om de har en ägare eller inte. 
Jag använder LEFT JOIN så att även konton utan ägare fortfarande visas i resultatet.*/



-- uppgift 7--

--Alternativ 1--

CREATE OR REPLACE FUNCTION LOGGA_IN (
    P_PNR    IN BANKKUND.PNR%TYPE,
    P_PASSWD IN BANKKUND.PASSWD%TYPE
) 
RETURN NUMBER AS
    V_PASSWD BANKKUND.PASSWD%TYPE;
BEGIN
    SELECT
        PASSWD
    INTO V_PASSWD
    FROM
        BANKKUND
    WHERE
        PNR = P_PNR;

    IF V_PASSWD = P_PASSWD THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;	

-- Testar att funktionen fungerar genom att göra: --

SELECT OBJECT_NAME, OBJECT_TYPE
FROM USER_OBJECTS
WHERE OBJECT_TYPE = 'FUNCTION'
AND OBJECT_NAME = 'LOGGA_IN';

-- och -- 

-- 1.	Testa med felaktigt lösenord--
SELECT LOGGA_IN('540126-1111', 'felaktigtlösenord') FROM dual;

-- 2.	Testa med felaktigt personnummer--
SELECT LOGGA_IN('540126-1110', 'olle45') FROM dual;

-- 3.	Testa med korrekta parametrar --
SELECT LOGGA_IN('540126-1111', 'olle45') FROM dual;

----------------------------------------------------


-- uppgift 8--

CREATE OR REPLACE FUNCTION get_saldo (
    p_knr IN konto.knr%TYPE  -- Inparameter: kontonummer
) 
RETURN NUMBER AS
    v_saldo konto.saldo%TYPE;  -- Variabel för att lagra saldo
BEGIN
    -- Hämta saldo för det givna kontonumret
    SELECT saldo INTO v_saldo
    FROM konto
    WHERE knr = p_knr;

    -- Returnera saldo
    RETURN v_saldo;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Om inget konto med det angivna kontonumret finns
        RAISE_APPLICATION_ERROR(-20002, 'Kontonumret finns inte.');
END;
/


-- test om funktionen finns --
SELECT object_name, status
FROM user_objects
WHERE object_type = 'FUNCTION'
AND object_name = 'GET_SALDO';


-- test om saldo--'
select get_saldo (5899)
from dual

-- varifera med konto table--
select * from konto;

-- se ett fel-kontonummer--
SELECT get_saldo(13) FROM dual;


------------------------------------------------------------

-- uppgift 9 --


-- Skapar eller ersätter en funktion som kontrollerar om en viss person (pnr)
-- har behörighet till ett visst konto (knr)
CREATE OR REPLACE FUNCTION get_behörighet (
    f_pnr IN bankkund.pnr%TYPE,   -- IN-parameter: personnummer
    f_knr IN kontoägare.knr%TYPE  -- IN-parameter: kontonummer
)
RETURN NUMBER AS
    v_pnr  bankkund.pnr%TYPE;     -- Variabel för att lagra resultatet av SELECT-frågan
BEGIN
    -- Hämtar personnummer från tabellen kontoägare där både pnr och knr matchar
    SELECT pnr INTO v_pnr 
    FROM kontoägare 
    WHERE pnr = f_pnr AND knr = f_knr;

    -- Om vi fick ett resultat som matchar personnumret, returnera 1 (behörig)
    IF v_pnr = f_pnr THEN 
        RETURN 1;
    ELSE 
        -- Annars returnera 0 (ej behörig)
        RETURN 0;
    END IF;

-- Om SELECT-satsen inte hittar någon rad, hanteras det här:
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Returnera 0 om ingen matchande rad hittades (ej behörig)
        RETURN 0;
END;
/

-- Test och varjfera--
SELECT object_name, status
FROM user_objects
WHERE object_type = 'FUNCTION'
AND object_name = 'GET_BEHÖRIGHET';

SELECT * FROM "KONTOÄGARE";

-- 0, 2.	Testa med fel personnummer--
SELECT get_behörighet('540126-1113', 123) AS test_fel_pnr FROM dual;
-- 0, 3.	Testa med fel kontonummer--
SELECT get_behörighet('540126-1111', 9999) AS test_fel_knr FROM dual;
--1, 4.	Testa med rätt parametrar--
SELECT get_behörighet('540126-1111', 123) AS test_korrekt FROM dual;



----------------------------------------------------------------


-- uppgift 10---

-- Skapa eller ersätt triggern som uppdaterar saldot efter en insättning
CREATE OR REPLACE TRIGGER aifer_insättning
AFTER INSERT ON insättning   -- Triggern aktiveras efter varje insättning i tabellen "insättning"
FOR EACH ROW                  -- Triggern körs för varje ny rad som läggs till i tabellen "insättning"
BEGIN
    -- Kontrollera om beloppet inte är NULL och konto finns
    IF :NEW.belopp IS NOT NULL AND :NEW.knr IS NOT NULL THEN
        -- Uppdaterar saldot i tabellen konto baserat på insättningen
        UPDATE konto
        SET saldo = saldo + :NEW.belopp  -- Lägg till det nya beloppet som just har satts in på kontot
        WHERE knr = :NEW.knr;             -- Matchar kontonumret från den insatta raden (insättning) med tabellen "konto"
    END IF;
END;
/



-- Test/verifierring --
SELECT *
FROM user_triggers
WHERE trigger_name = 'AIFER_INSÄTTNING';


-- inget saldo--
SELECT * from konto;

-- insert saldo--
INSERT INTO insättning (radnr, pnr, knr, belopp, datum)
VALUES (radnr_seq.NEXTVAL, '540126-1111', '123', 2500, SYSDATE);

-- ny saldo--
SELECT * from konto;

-----------------------------------------------------------

-- uppgift 11--

CREATE OR REPLACE TRIGGER bifer_uttag
BEFORE INSERT ON uttag  -- Triggern aktiveras innan ett uttag görs i tabellen "uttag"
FOR EACH ROW
DECLARE
    v_saldo konto.saldo%TYPE;  -- Variabel för att hålla det aktuella saldot från kontot
BEGIN
    -- Anropa funktionen get_saldo för att hämta saldot för det aktuella kontot (knr)
    v_saldo := get_saldo(:NEW.knr);  -- :NEW.knr används för att referera till det kontonummer som ska användas i uttaget
    
    -- Kontrollera om beloppet som ska tas ut är större än det aktuella saldot
    IF (v_saldo - :new.belopp) < 0 THEN
        -- Om uttagsbeloppet är större än saldot, stoppa insättningen och ge ett felmeddelande
        RAISE_APPLICATION_ERROR(-20001, 'Du har inet tillräckligt med pengar på kontot för detta uttag.');
    END IF;
END;
/

-- Test/verifierring --
SELECT *
FROM user_triggers
WHERE trigger_name = 'BIFER_UTTAG';



--- ORA-20001: Du har inet tillräckligt med pengar på kontot för detta uttag.--
INSERT INTO uttag (radnr, pnr, knr, belopp, datum)
VALUES (radnr_seq.NEXTVAL, '540126-1111', '123', 8000, SYSDATE);

SELECT * from konto;
SELECT * from uttag;

------------------------------------

--uppgift 12--

CREATE OR REPLACE TRIGGER aifer_uttag
AFTER INSERT ON uttag  -- Triggern aktiveras efter varje insättning i tabellen "uttag"
FOR EACH ROW
DECLARE
    v_saldo konto.saldo%TYPE;  -- Variabel för att hålla det aktuella saldot från kontot
BEGIN
    -- Hämta det aktuella saldot för det kontonummer som är kopplat till uttaget
    SELECT saldo INTO v_saldo
    FROM konto
    WHERE knr = :NEW.knr;  -- :NEW.knr refererar till det kontonummer som finns i den nyligen insatta raden i uttag

    -- Uppdatera saldot genom att dra av uttagsbeloppet
    UPDATE konto
    SET saldo = v_saldo - :NEW.belopp  -- Dra av uttagsbeloppet från det aktuella saldot
    WHERE knr = :NEW.knr;  -- Matchar kontonumret med det som finns i den nya raden i uttag
END;
/

	

/
-- Test/verifierring --
SELECT *
FROM user_triggers
WHERE trigger_name = 'AIFER_UTTAG';

INSERT INTO uttag (radnr, pnr, knr, belopp, datum)
VALUES (radnr_seq.NEXTVAL, '540126-1111', '123', 1000, SYSDATE);

SELECT * from konto;
SELECT * from uttag;
SELECT * from insättning;

--------------------------------------------------------------------------------------

-- uppgift 13--

CREATE OR REPLACE TRIGGER bifer_överföring
BEFORE INSERT ON överföring
FOR EACH ROW
DECLARE
    v_saldo konto.saldo%TYPE;
BEGIN
    -- Hämta saldot från belastningskontot med hjälp av funktionen get_saldo
    v_saldo := get_saldo(:NEW.från_knr);

    -- Kontrollera om det finns tillräckligt med pengar för att genomföra överföringen
    IF v_saldo < :NEW.belopp THEN
        RAISE_APPLICATION_ERROR(-20003, 'Otillräckligt saldo på från-kontot för överföring.');
    END IF;
END;
/

-- Test/verifierring --
SELECT *
FROM user_triggers
WHERE trigger_name = 'BIFER_ÖVERFÖRING';

-- Fungerar ***1000***---
INSERT INTO överföring (radnr, pnr, från_knr, till_knr, belopp, datum)
VALUES (radnr_seq.NEXTVAL, '540126-1111', '123', 5899, 1000, SYSDATE);

--fungerar inte ORA-20003: Otillräckligt saldo på från-kontot för överföring.**3000** --- 
INSERT INTO överföring (radnr, pnr, från_knr, till_knr, belopp, datum)
VALUES (radnr_seq.NEXTVAL, '540126-1111', '123', 5899, 3000, SYSDATE);


--------------------------------------------------------------------

-- uppgift 14--
-- Triggern aktiveras efter att en ny överföring har registrerats
CREATE OR REPLACE TRIGGER aifer_överföring
AFTER INSERT ON överföring
FOR EACH ROW
BEGIN
    -- Minska saldot på från-kontot
    UPDATE konto
    SET saldo = saldo - :NEW.belopp
    WHERE knr = :NEW.från_knr;

    -- Öka saldot på till-kontot
    UPDATE konto
    SET saldo = saldo + :NEW.belopp
    WHERE knr = :NEW.till_knr;
END;
/

-- Test/verifierring --
SELECT *
FROM user_triggers
WHERE trigger_name = 'AIFER_ÖVERFÖRING';

--Internöverföring--

INSERT INTO överföring (radnr, pnr, från_knr, till_knr, belopp, datum)
VALUES (radnr_seq.NEXTVAL, '540126-1111', '123', 5899, 1000, SYSDATE);

INSERT INTO överföring (radnr, pnr, från_knr, till_knr, belopp, datum)
VALUES (radnr_seq.NEXTVAL, '540126-1111', '5899', 123, 305, SYSDATE);

--Se konto--
SELECT * from konto;

------------------------------------------------------------------

-- uppgfit 15---

CREATE OR REPLACE PROCEDURE do_insättning (
    p_pnr    IN insättning.pnr%TYPE,    -- Personnummer
    p_knr    IN insättning.knr%TYPE,    -- Kontonummer
    p_belopp IN insättning.belopp%TYPE  -- Belopp att sätta in
)
AS
    v_radnr  NUMBER(9);                  -- Variabel för radnummer
    v_saldo  konto.saldo%TYPE;           -- Variabel för att lagra saldot efter insättningen

    ogiltigt_belopp EXCEPTION;           -- Eget fel för negativt belopp
BEGIN
    -- Kontrollera att beloppet inte är negativt
    IF p_belopp <= 0 THEN
        RAISE ogiltigt_belopp;           -- Om beloppet är negativt eller 0, kasta ett fel
    END IF;

    -- Generera nästa radnummer från sekvens
    SELECT radnr_seq.NEXTVAL INTO v_radnr FROM dual;

    -- Lägg till insättningen
    INSERT INTO insättning (radnr, pnr, knr, belopp, datum)
    VALUES (v_radnr, p_pnr, p_knr, p_belopp, SYSDATE);

    COMMIT; -- Bekräfta transaktionen (valfritt i procedurer, beroende på hur ni jobbar med transaktionshantering)

    -- Hämta nya saldot
    v_saldo := get_saldo(p_knr);

    -- Skriv ut resultat
    DBMS_OUTPUT.PUT_LINE('Insättning genomförd. Aktuellt saldo: ' || v_saldo || ' kr');

EXCEPTION
    WHEN ogiltigt_belopp THEN
        RAISE_APPLICATION_ERROR(-20020, 'Beloppet måste vara större än 0.');  -- Felmeddelande om beloppet är negativt eller 0

    WHEN OTHERS THEN
        -- Felhantering med feltext- TYPE fel personnummer, ELLER FELKONTO ---
        DBMS_OUTPUT.PUT_LINE('Något gick fel vid insättningen: ' || SQLERRM);
END;
/


-- test--

SELECT object_name, status
FROM user_objects
WHERE object_type = 'PROCEDURE'
AND object_name = 'DO_INSÄTTNING';

--Sättar in pengar--
EXEC do_insättning('540126-1111', 123, 582);

--Se konto--
SELECT * from konto;

---------------------------------------------------


-- uppgift 16--


-- 1.	Verifiera innehåll i tabellen KONTO före insättning sker-- 
SELECT * FROM konto WHERE knr = 5899;

-- 2.	Verifiera innehåll i tabellen INSÄTTNING före insättning sker --
SELECT * FROM insättning WHERE knr = 5899;

-- 3.	Testa med fel personnummer --
EXEC do_insättning('840101-1111', 5899, 100);

-- 4.	Testa med fel kontonummer --
EXEC    do_insättning('540126-1111', 1111, 4600);

-- 5.	Testa med negativt belopp --
EXEC    do_insättning('540126-1111', 5899, -250);

-- 6.	Testa med rätt parametrar --
EXEC    do_insättning('540126-1111', 5899, 1250);

-- 7.	Verifiera innehållet i tabellen INSÄTTNING efter insättning skett --
SELECT * FROM insättning WHERE knr = 5899 ORDER BY datum DESC;

-- 8.	Verifiera saldo i tabellen KONTO efter insättning skett -- 
SELECT * FROM konto WHERE knr = 5899;


----------------------------------------------


--- Uppgift 17---

CREATE OR REPLACE PROCEDURE do_uttag (	
    p_pnr    IN uttag.pnr%TYPE,         -- Inparameter: Personnummer
    p_knr    IN uttag.knr%TYPE,         -- Inparameter: Kontonummer
    p_belopp IN uttag.belopp%TYPE       -- Inparameter: Belopp att ta ut
)
AS
    v_radnr      NUMBER(9);             -- Variabel för att lagra nytt radnummer från sekvens
    v_behörighet NUMBER(1);             -- Variabel som anger om personen är behörig (1) eller ej (0)

    obehörig         EXCEPTION;         -- Egendefinierat undantag för obehörig åtkomst
    ogiltigt_belopp  EXCEPTION;         -- Undantag för ogiltigt (negativt eller noll) belopp
BEGIN
    -- Kontrollera om beloppet är negativt eller 0
    IF p_belopp <= 0 THEN
        RAISE ogiltigt_belopp;
    END IF;

    -- Kontrollera behörighet med hjälp av funktionen get_behörighet
    v_behörighet := get_behörighet(p_pnr, p_knr);
    
    -- Om användaren är behörig:
    IF v_behörighet = 1 THEN
        -- Hämta nästa värde från sekvens för radnummer
        SELECT radnr_seq.NEXTVAL INTO v_radnr FROM dual;

        -- Infoga ny rad i tabellen uttag med angivna parametrar
        INSERT INTO uttag (radnr, pnr, knr, belopp, datum)
        VALUES (v_radnr, p_pnr, p_knr, p_belopp, SYSDATE);
    
    ELSE
        -- Om inte behörig, kasta undantag
        RAISE obehörig;
    END IF;

EXCEPTION
    -- Fångar det egendefinierade undantaget "obehörig"
    WHEN obehörig THEN
        RAISE_APPLICATION_ERROR(-20006, 'Behörighet saknas.');

    -- Fångar ogiltiga belopp (negativt eller 0)
    WHEN ogiltigt_belopp THEN
        RAISE_APPLICATION_ERROR(-20008, 'Beloppet måste vara ett positivt värde större än 0.');
END;
/


--test--

SELECT object_name, status
FROM user_objects
WHERE object_type = 'PROCEDURE'
AND object_name = 'DO_UTTAG';


--fungerar--
EXEC do_uttag('540126-1111', 5899, 582);

-- ej fungerar fel pnr, ORA-20006: Behörighet saknas.--
EXEC do_uttag('540126-1110', 123, 582);

-- ej fungerar fel knr, ORA-20006: Behörighet saknas.--
EXEC do_uttag('540126-1111', 1111, 582);

SELECT * FROM UTTAG;

---------------------------------------------------------------------

--- uppgift 18---


Verifiera do_uttag genom att:
-- 1.	Verifiera innehåll i tabellen KONTO före uttag sker --

SELECT * FROM konto WHERE knr = 123;



-- 2.	Verifiera innehåll i tabellen UTTAG före uttag sker-- 
SELECT * FROM uttag WHERE knr = 123;


-- 3.	Testa med fel personnummer ** ORA-20006: Behörighet saknas.**---
EXEC do_uttag('19840101-1111', 123, 500);

-- 4.	Testa med fel kontonummer--

EXEC do_uttag('540126-1111', 999, 690);

-- 5.	Testa med för stort belopp, ** ORA-20001: Du har inte tillräckligt med pengar på kontot för detta uttag.**---
EXEC do_uttag('540126-1111', 123, 150000);

-- 6.	Testa med negativt belopp ** ORA-20008: Beloppet måste vara ett positivt värde större än 0.**--
EXEC do_uttag('540126-1111', 123, -300);

-- 7.	Testa med rätt parametrar ** PL/SQL procedure successfully completed.**-- 
EXEC do_uttag('540126-1111', 123, 50);

-- 8.	Verifiera innehållet i tabellen UTTAG efter uttag skett--

SELECT * FROM uttag WHERE pnr = '540126-1111' AND knr = 123;

-- 9.	Verifiera innehållet i tabellen KONTO efter uttag skett--

SELECT saldo FROM konto WHERE knr = 123;



------------------------------------------------------------

--upgift 19-- 

CREATE OR REPLACE PROCEDURE do_överföring (
    p_pnr        IN överföring.pnr%TYPE,
    p_från_knr   IN överföring.från_knr%TYPE,
    p_till_knr   IN överföring.till_knr%TYPE,
    p_belopp     IN överföring.belopp%TYPE
)
AS
    v_saldo_fr     konto.saldo%TYPE;
    v_saldo_t      konto.saldo%TYPE;
    v_radnr        NUMBER(9);
    v_behörighet   NUMBER(1);
    v_tmp          konto.knr%TYPE;

    obehörig         EXCEPTION;
    ogiltigt_belopp  EXCEPTION;
BEGIN
    -- Kontroll: Beloppet måste vara positivt
    IF p_belopp <= 0 THEN
        RAISE ogiltigt_belopp;
    END IF;

    -- Kontroll: Från-konto måste finnas (annars NO_DATA_FOUND kastas)
    SELECT knr INTO v_tmp FROM konto WHERE knr = p_från_knr;

    -- Kontroll: Till-konto måste finnas (annars NO_DATA_FOUND kastas)
    SELECT knr INTO v_tmp FROM konto WHERE knr = p_till_knr;

    -- Kontrollera behörighet
    v_behörighet := get_behörighet(p_pnr, p_från_knr);

    IF v_behörighet = 1 THEN
        SELECT radnr_seq.NEXTVAL INTO v_radnr FROM dual;

        INSERT INTO överföring (radnr, pnr, från_knr, till_knr, belopp, datum)
        VALUES (v_radnr, p_pnr, p_från_knr, p_till_knr, p_belopp, SYSDATE);

        COMMIT;

        v_saldo_fr := get_saldo(p_från_knr);
        v_saldo_t := get_saldo(p_till_knr);

        DBMS_OUTPUT.PUT_LINE('Saldo efter genomförd överföring:');
        DBMS_OUTPUT.PUT_LINE('Ditt konto: ' || v_saldo_fr || ' kr');
        DBMS_OUTPUT.PUT_LINE('Mottagande konto: ' || v_saldo_t || ' kr');
    ELSE
        RAISE obehörig;
    END IF;

-- Felhantering
EXCEPTION
    WHEN obehörig THEN
        RAISE_APPLICATION_ERROR(-20007, 'Behörighet saknas.');
    WHEN ogiltigt_belopp THEN
        RAISE_APPLICATION_ERROR(-20009, 'Beloppet måste vara större än 0.');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'Det kontonummer du försöker använda finns inte.');
END;
/



-- test---
SELECT object_name, status
FROM user_objects
WHERE object_type = 'PROCEDURE'
AND object_name = 'DO_ÖVERFÖRING';

-----------------------------------------------------

-- Uppgift 20--


Verifiera do_överföring genom att:
--  1.	Verifiera innehåll i tabellen KONTO före överföring sker--
SELECT * FROM konto;


-- 2.	Verifiera innehåll i tabellen ÖVERFÖRING före överföring sker--
SELECT * FROM överföring;


-- 3.	Testa med fel personnummer ** ORA-20007: Behörighet saknas.**--

EXEC do_överföring('540126-1110', 123, 5899, 100);


-- 4.	Testa med fel från-kontonummer * *ORA-20007: Behörighet saknas.**---

EXEC do_överföring('540126-1111', 124, 5899, 100);

-- 5.	Testa med fel till-kontonummer,** ORA-20010: Det kontonummer du försöker använda finns inte.**--

EXEC do_överföring('540126-1111', 123, 899, 100);

-- 6.	Testa med för stort belopp, ** ORA-20003: Otillräckligt saldo på från-kontot för överföring.** --

EXEC do_överföring('540126-1111', 123, 5899, 150000);

-- 7.	Testa med negativt belopp, ** ORA-20009: Beloppet måste vara större än 0.** ---

EXEC do_överföring('540126-1111', 123, 5899, -120);

--8.	Testa med rätt parametrar **PL/SQL procedure successfully completed.**-- 

EXEC do_överföring('540126-1111', 123, 5899, 100);

-- 9.	Verifiera innehållet i tabellen ÖVERFÖRING efter överföring skett -- 

SELECT * FROM överföring WHERE från_knr = 123 AND till_knr = 5899;


-- 10.	Verifiera innehållet i tabellen KONTO efter överföring skett -- 

SELECT * FROM konto WHERE knr IN (123, 5899 );

