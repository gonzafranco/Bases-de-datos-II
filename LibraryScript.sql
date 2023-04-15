IF db_id('library') IS NULL
BEGIN
	CREATE DATABASE library
END
GO

USE library;

CREATE TABLE Autores (
    authorId int NOT NULL PRIMARY KEY,
    Nombre varchar(50) NOT NULL,
    Apellido varchar(70) NOT NULL
);

CREATE TABLE Estudiantes (
    studentId int NOT NULL PRIMARY KEY,
    Nombre varchar(20) NOT NULL,
    Apellido varchar(20) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Genero varchar(10) NOT NULL,
    Clase varchar(7) NOT NULL,
    Punto int NOT NULL
);

CREATE TABLE Tipos (
    typeId int NOT NULL PRIMARY KEY,
    DescripcionTipo varchar(30) NOT NULL
);

CREATE TABLE Libros (
    bookId int NOT NULL PRIMARY KEY,
    NombreLibro varchar(90) NOT NULL,
    CantPaginas int NOT NULL,
    Punto int NOT NULL,
    authorId int NOT NULL,
    typeId int NOT NULL,
    CONSTRAINT FK_Libros_Autores FOREIGN KEY (authorId) REFERENCES Autores(authorId),
    CONSTRAINT FK_Libros_Tipos FOREIGN KEY (typeId) REFERENCES Tipos(typeId)
);

CREATE TABLE Prestamos (
    borrowId int NOT NULL PRIMARY KEY,
    studentId int NOT NULL,
    bookId int NOT NULL,
    DiaPrestamo datetime NOT NULL,
    DiaCompra datetime NOT NULL,
    CONSTRAINT FK_Prestamos_Estudiantes FOREIGN KEY (studentId) REFERENCES Estudiantes(studentId),
    CONSTRAINT FK_Prestamos_Libros FOREIGN KEY (bookId) REFERENCES Libros(bookId)
);
