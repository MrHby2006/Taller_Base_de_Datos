DROP TABLE SUELDO_TENTATIVO;
DROP TABLE LOG_ERRORES;

CREATE TABLE sueldo_tentativo(
    employee_id       NUMBER PRIMARY KEY,
    nombre_empleado   VARCHAR2(100),
    sueldo_actual     NUMBER(10,2),
    porcentaje        NUMBER(5,2),
    sueldo_nuevo      NUMBER(10,2),
    fecha_proceso     DATE
);

CREATE TABLE log_errores(
    log_id            NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mensaje           VARCHAR2(4000)NOT NULL,
    fecha_error       DATE DEFAULT SYSDATE
);

DECLARE
    V_OPCION        NUMBER := &OPCION;
    V_ID_EMPLEADO   NUMBER;
    V_NOMBRE        VARCHAR2(50);
    V_SUELDO        NUMBER;
    V_PORCENTAJE    NUMBER;
    V_NUEVO_SUELDO  NUMBER;
    
    E_SUPERA_LIMITE EXCEPTION;
BEGIN
    IF V_OPCION = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Simular aumento para un empleado');
        V_ID_EMPLEADO := &ID_EMPLEADO;
        
        SELECT FIRST_NAME||' '||LAST_NAME, SALARY
        INTO V_NOMBRE, V_SUELDO
        FROM EMPLOYEES
        WHERE EMPLOYEE_ID = V_ID_EMPLEADO;
        
        IF V_SUELDO < 5000 THEN
            V_PORCENTAJE := 15;
            V_NUEVO_SUELDO := V_SUELDO * 1.15;
        ELSIF V_SUELDO BETWEEN 5000 AND 10000 THEN
            V_PORCENTAJE := 10;
            V_NUEVO_SUELDO := V_SUELDO * 1.10;
        ELSIF V_SUELDO > 10000 THEN
            V_PORCENTAJE := 5;
            V_NUEVO_SUELDO := V_SUELDO * 1.05;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Id del empleado: '||V_ID_EMPLEADO);
        DBMS_OUTPUT.PUT_LINE('Nombre del empleado: '||V_NOMBRE);
        DBMS_OUTPUT.PUT_LINE('Sueldo actual del empleado: $'||V_SUELDO);
        DBMS_OUTPUT.PUT_LINE('Porcentaje de aumento aplicado: '||V_PORCENTAJE||'%');
        DBMS_OUTPUT.PUT_LINE('Nuevo sueldo calculado: $'||V_NUEVO_SUELDO);
        
        IF V_NUEVO_SUELDO > 12000 THEN
            DBMS_OUTPUT.PUT_LINE('El nuevo sueldo supera el monto máximo permitido');
        END IF;
    ELSIF V_OPCION = 2 THEN
        DBMS_OUTPUT.PUT_LINE('Procesar aumento para todos los empleados.');
        FOR R_EMPLEADO IN (SELECT EMPLOYEE_ID AS ID_EMPLEADO,
                                  FIRST_NAME||' '||LAST_NAME AS NOMBRE,
                                  SALARY AS SALARIO
                           FROM EMPLOYEES)
        LOOP
            IF R_EMPLEADO.SALARIO < 5000 THEN
                V_PORCENTAJE := 15;
                V_NUEVO_SUELDO := R_EMPLEADO.SALARIO * 1.15;
            ELSIF E_EMPLEADO.SUELDO BETWEEN 5000 AND 10000 THEN
                V_PORCENTAJE := 10;
                V_NUEVO_SUELDO := R_EMPLEADO.SALARIO * 1.10;
            ELSIF R_EMPLEADO.SUELDO > 10000 THEN
                V_PORCENTAJE := 5;
                V_NUEVO_SUELDO := R_EMPLEADO.SALARIO * 1.05;
            END IF;
            
            IF V_NUEVO_SUELDO > 12000 THEN
                RAISE E_SUPERA_LIMITE;  
            END IF;
            
            INSERT INTO SUELDO_TENTATIVO VALUES(R_EMPLEADO.ID_EMPLEADO, R_EMPLEADO.NOMBRE, R_EMPLEADO.SALARIO, V_PORCENTAJE, V_NUEVO_SUELDO, SYSDATE);
        END LOOP;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('El empleado con id '||V_ID_EMPLEADO||' no existe');
    WHEN E_SUPERA_LIMITE THEN
        INSERT INTO LOGS_ERRORES (MENSAJE) VALUES('Hubo un error, el sueldo del empleado superó el límite');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Se produjo un error');
END;