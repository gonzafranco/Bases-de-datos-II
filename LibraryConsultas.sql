USE library;

-- 2) Agregar estas restricciones al modelo ya creado
--	2.1
ALTER TABLE Libros
ADD CONSTRAINT CHK_CantPaginas CHECK (CantPaginas > 0);

--	2.2
ALTER TABLE Libros
ADD CONSTRAINT DEF_punto
DEFAULT 1 FOR Punto;

/* 3) Listar los Libros (nombres y cantidad de páginas) ordenado por la cantidad de páginas
descendentes
*/

SELECT NombreLibro,
	   CantPaginas
FROM [dbo].[Libros]
ORDER BY CantPaginas

/*  4) Obtener los primeros 4 Estudiantes (StudentId, Nombre+Apellido, fecha de Nacimiento)
	ordenado por fecha de nacimiento ascendente
*/
SELECT TOP 4 studentId, 
	   CONCAT(Nombre,' ', Apellido) as nombre, 
	   FechaNacimiento
FROM [dbo].[Estudiantes]
ORDER BY FechaNacimiento asc

/* 5) Luego ejecutar la misma consulta con la cláusula WITH TIES y explicar brevemente que es
lo que puede verificar
*/

SELECT TOP 4 WITH TIES studentId, 
	   CONCAT(Nombre,' ', Apellido) as nombre, 
	   FechaNacimiento
FROM [dbo].[Estudiantes]
ORDER BY FechaNacimiento asc

/* La clausula TOP 4 va a devolver las cuatro primeras filas con los estudiantes con la fecha de nacimiento mas antigua
   La clausula WITH TIES va a devolver los demas estudiantes que compartan esa fecha de nacimiento.
   Es por eso que la segunda consulta devuelve un alumno adicional con esta fecha de nacimiento : 1999-01-14
*/


/* 6) Informar los Prestamos (borrowId,studentId,bookId, * CantDias) *Cantidad de días que
llevan prestados los libros.
*/

SELECT	borrowId,
		studentId,
		bookId,
		DATEDIFF(DAY,DiaCompra,CURRENT_TIMESTAMP) as Dias,
		DiaCompra
FROM [dbo].[Prestamos]

/*
7) Informar los Prestamos (borrowId, studentId, Nombre y Apellido del estudiante, bookId,
NombreLibro, * CantDias) * Cantidad de días que llevan prestados los libros, de aquellos
libros comprados en el mes de agosto
*/

SELECT	borrowId,
		p.studentId, 
		CONCAT(e.Apellido,' ', e.Nombre) as 'Apellido y nombre' ,
		p.bookId, 
		l.NombreLibro,
		p.DiaCompra,
		DATEDIFF(DAY,p.DiaCompra,CURRENT_TIMESTAMP) as Dias
FROM [dbo].[Prestamos] as p
JOIN [dbo].[Estudiantes] as e ON (p.studentId = e.studentId)
JOIN [dbo].[Libros] as l ON (p.bookId = l.bookId)
WHERE MONTH(p.DiaCompra) = 8

/*
8) Informar todos los Estudiantes que nunda han realizado un prestamo. (Pueden utilizar
Subconsulta o LEFT JOIN)
*/

SELECT	e.studentId,
		Nombre,
		Apellido,
		FechaNacimiento,
		Genero,
		Clase,
		Punto
FROM   [dbo].[Estudiantes] as e
LEFT JOIN [dbo].[Prestamos] as p ON (p.studentId = e.studentId)
WHERE p.borrowId IS NULL

/*
9) Insertar dos nuevos Estudiante con valores seleccionados por usted.
Luego Re-Ejecutar la consulta del punto 8 y realizar una breve concusión del resultado
obtenido
*/

INSERT [dbo].[Estudiantes] ([studentId], [Nombre], [Apellido], [FechaNacimiento], [Genero], [Clase], [Punto] )
VALUES (506, N'Franco', N'Gonzalez', CAST(N'1996-10-25' AS Date), N'M', N'9B', 1916)
INSERT [dbo].[Estudiantes] ([studentId], [Nombre], [Apellido], [FechaNacimiento], [Genero], [Clase], [Punto] )
VALUES (507, N'Fulano', N'Fulanito', CAST(N'1998-10-28' AS Date), N'M', N'12D', 1215)

-- La consulta anterior devuelve los dos alumnos insertados a la base de datos ya que nunca realizaron un presmato en la biblioteca
-- Es decir, estos alumnos no tienen actividad en la tabla Prestamos


/*
10) Realizar una copia derivada desde la tabla Estudiantes llamada Estudiantes_cpy. Utilizar
la sentencia SELECT INTO o INSERT SELECT
*/

SELECT *
INTO Estudiantes_cpy
FROM Estudiantes

/*
11) Realizar la actualización y corrección de préstamo (DiaPrestamo) incrementando en 5 la
cantidad de años.
*/

UPDATE [dbo].[Prestamos]
SET DiaPrestamo = DATEADD(YEAR, 5, DiaPrestamo)

/*
12) Luego de la actualización realizada en el punto 11 realizar una consulta que informe el
tiempo promedio de préstamo por tipo de libro, solo de aquellos tipos de libros cuyo
promedio supera los 70 dias.
*/

SELECT	DescripcionTipo,
		AVG(DATEDIFF(DAY,p.DiaCompra,CURRENT_TIMESTAMP)) as Dias
FROM [dbo].[Prestamos] as p
JOIN [dbo].[Libros] as l ON (p.bookId = l.bookId)
JOIN [dbo].[Tipos] as t ON (l.typeId = t.typeId)
GROUP BY DescripcionTipo
HAVING AVG(DATEDIFF(DAY,p.DiaCompra,CURRENT_TIMESTAMP)) > 70


-- 13) Informar el top 5 de los autores más prestados.

SELECT TOP 5 a.Apellido, 
			 COUNT(*) as Prestamos
FROM [dbo].[Autores] as  a
JOIN [dbo].[Libros] as l ON (a.authorId = l.authorId)
JOIN [dbo].[Prestamos] as p ON (l.bookId = p.bookId)
GROUP BY  a.Apellido
ORDER BY Prestamos DESC; --

-- 14) A partir de la consulta del punto 8 realizar una vista llamada vw_EstudiantesSinPrestamos

CREATE VIEW vw_estudiantes_sin_prestamos AS
SELECT	e.studentId,
		Nombre,
		Apellido,
		FechaNacimiento,
		Genero,
		Clase,
		Punto
FROM   [dbo].[Estudiantes] as e
LEFT JOIN [dbo].[Prestamos] as p ON (p.studentId = e.studentId)
WHERE p.borrowId IS NULL

SELECT * FROM vw_estudiantes_sin_prestamos

/*
15) A partir de la consulta del punto 7 realizar un procedimiento almacenado que reciba
como parámetro el mes a consulta.
*/

CREATE PROCEDURE reporte_prestamos_por_mes
    @mes INT
AS
BEGIN
SELECT	borrowId,
		p.studentId, 
		CONCAT(e.Apellido,' ', e.Nombre) as 'Apellido y nombre' ,
		p.bookId, 
		l.NombreLibro,
		p.DiaCompra,
		DATEDIFF(DAY,p.DiaCompra,CURRENT_TIMESTAMP) as Dias
FROM [dbo].[Prestamos] as p
JOIN [dbo].[Estudiantes] as e ON (p.studentId = e.studentId)
JOIN [dbo].[Libros] as l ON (p.bookId = l.bookId)
WHERE MONTH(p.DiaCompra) = @mes
END;

-- llamar a funcion 
EXEC reporte_prestamos_por_mes @mes = 8;



/*
16) Realizar un procedimiento almacenado que reciba como parámetro el género, la clase y
fecha de préstamo desde y hasta. Deberá informar estudiantes que hayan concretado
prestamos y que cumplan con las condiciones que reciba como parámetro. El
procedimiento deberá informar Nombre y apellido del estudiante, Libro y fecha en que
se le prestó
*/

CREATE PROCEDURE reporte_prestamos_por_genero_clase
    @genero  VARCHAR(10),
	@clase  VARCHAR(7),
	@fechaDesde DATE,
	@fechaHasta DATE
AS
BEGIN
SELECT	e.Nombre,
		e.Apellido,
		e.Genero,
		e.Clase,
		l.NombreLibro,
		p.DiaPrestamo
FROM   [dbo].[Estudiantes] as e
JOIN [dbo].[Prestamos] as p ON (p.studentId = e.studentId)
JOIN [dbo].[Libros] as l ON (p.bookId = l.bookId)
WHERE e.Genero = @genero
AND e.Clase = @clase
AND p.DiaPrestamo BETWEEN @fechaDesde AND  @fechaHasta
END;

-- llamar funcion
EXEC reporte_prestamos_por_genero_clase
@genero = 'F',@clase = '11B', @fechaDesde = '2020-01-01' , @fechaHasta = '2020-12-01';


/*
17) Crear una función llamada udf_EdadEstudiante que reciba como parámetros la el
studentId y retorne la edad
*/


CREATE FUNCTION udf_EdadEstudiante
	(@estid int)
	RETURNS int
AS
BEGIN
	DECLARE @edad int;
	
	SELECT @edad = DATEDIFF(YEAR, FechaNacimiento, CURRENT_TIMESTAMP)
	FROM [library].[dbo].[Estudiantes]
	WHERE studentId = @estid;

	RETURN @edad;
END;

SELECT dbo.udf_EdadEstudiante(506) as edad


-- 18) Eliminar el Tipo de Libro identificado con el typeId = 1.

DELETE FROM [dbo].[Tipos] WHERE typeId = 1

-- El resultado fue: 
-- The DELETE statement conflicted with the REFERENCE constraint "FK_Libros_Tipos". The conflict occurred in database "library", table "dbo.Libros", column 'typeId'.
-- Esto se por la constraint de la clave foranea. El error esta bien que ocurra porque esto permite la integridad de datos de las otras tablas

-- 19) Ejecutar la consulta del punto 8 insertando e informando el resultado desde una CTE

WITH EstudiantesSinPrestamo_cte (studentId, Nombre, Apellido)
AS (
    SELECT e.studentId,
           Nombre,
           Apellido
    FROM [dbo].[Estudiantes] AS e
    LEFT JOIN [dbo].[Prestamos] AS p ON p.studentId = e.studentId
    WHERE p.borrowId IS NULL
)
SELECT * FROM EstudiantesSinPrestamo_cte


-- 20) Investigar qué forma hay de emular un order by en un view. Este view da error. Solucionarlo.
CREATE VIEW vw_Libros_Grandes
AS
SELECT  [bookId]
,[NombreLibro]
,[CantPaginas]
FROM [dbo].[Libros]
WHERE [CantPaginas] >300
ORDER BY CantPaginas OFFSET 0 ROWS

SELECT * FROM vw_libros_grandes


/*
21) Escribir un script simple que cree dos variables de tipo enteras (una llamada cantM y otra
llamada cantF), y les asigne los valores de la cantidad de Estudiantes Masculinos y
femeninos respectivamente.

Luego informar por pantalla que genero tiene mas alumnos.

*/

BEGIN

DECLARE @alumnos_masculinos int;
DECLARE @alumnos_femeninos int;

SET @alumnos_masculinos = (SELECT count(*) FROM dbo.Estudiantes WHERE Genero = 'M');
SET @alumnos_femeninos = (SELECT count(*) FROM dbo.Estudiantes WHERE Genero = 'F');

--SELECT @alumnos_masculinos M, @alumnos_femeninos F, (@alumnos_masculinos + @alumnos_femeninos) Total

SELECT CASE 
	WHEN  @alumnos_masculinos > @alumnos_femeninos THEN 'Hay mas estudiantes masculinos en el sistema de la libreria'
	WHEN  @alumnos_masculinos < @alumnos_femeninos THEN 'Hay mas estudiantes femeninos en el sistema de la libreria'
	ELSE 'Hay la misma cantidad de alumnos femeninos y masculinos en el sistema de la libreria'
	END

END;

-- 22) Informar de cada libro cual fue el primer estudiante que lo pidio y la fecha.

SELECT l.NombreLibro, 
	   CONCAT(e.Apellido, ' ', e.Nombre) AS Estudiante,
	   p.DiaPrestamo AS Fecha
FROM [dbo].[Libros] AS l
JOIN [dbo].[Prestamos] AS p ON (l.bookId = p.bookId)
JOIN [dbo].[Estudiantes] AS e ON (p.studentId = e.studentId)
WHERE p.DiaPrestamo = (SELECT MIN(p2.DiaPrestamo) 
						FROM [dbo].[Prestamos] AS p2 
						WHERE p2.bookId = p.bookId
						GROUP BY bookId)
ORDER BY l.NombreLibro;

/*
SELECT  p.bookId, 
		l.NombreLibro,
		(e.Nombre +' '+ e.Apellido) as nombreAlumno,
		p.DiaPrestamo
FROM dbo.Prestamos p
JOIN dbo.Libros l ON (p.bookId = l.bookId)
JOIN dbo.Estudiantes e ON (e.studentId =p.studentId)
WHERE p.bookId = 1
ORDER BY p.DiaPrestamo asc
*/