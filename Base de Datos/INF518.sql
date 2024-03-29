USE [master]
GO
/****** Object:  Database [INF518]    Script Date: 19/7/2019 8:16:06 p. m. ******/
CREATE DATABASE [INF518]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'INF518', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\INF518.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'INF518_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\INF518_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [INF518] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [INF518].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [INF518] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [INF518] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [INF518] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [INF518] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [INF518] SET ARITHABORT OFF 
GO
ALTER DATABASE [INF518] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [INF518] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [INF518] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [INF518] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [INF518] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [INF518] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [INF518] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [INF518] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [INF518] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [INF518] SET  DISABLE_BROKER 
GO
ALTER DATABASE [INF518] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [INF518] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [INF518] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [INF518] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [INF518] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [INF518] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [INF518] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [INF518] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [INF518] SET  MULTI_USER 
GO
ALTER DATABASE [INF518] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [INF518] SET DB_CHAINING OFF 
GO
ALTER DATABASE [INF518] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [INF518] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [INF518] SET DELAYED_DURABILITY = DISABLED 
GO
USE [INF518]
GO
/****** Object:  UserDefinedFunction [dbo].[fc_montoEstudiante]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fc_montoEstudiante](
	@estudianteID INT
)
RETURNS DECIMAL
AS
BEGIN
	-- Declare the return variable here
	DECLARE @montoCreditos DECIMAL;
	DECLARE @costoInscripcion DECIMAL;

	SELECT 
		@costoInscripcion= TE.CostoInscripcion
	FROM tblEstudiantes EST
	INNER JOIN tblTipoEstudiantes TE
		ON EST.TipoEstudianteID = TE.TipoEstudianteID
	WHERE 
		EstudianteID = 5

	SELECT 
		@montoCreditos = (SUM(ASIG.Creditos) * SUM(TE.CostoCredito))
	FROM tblInscripcion INS
	INNER JOIN tblDetalleInscripcion DI	
		ON INS.InscripcionID = DI.InscripcionID
	INNER JOIN tblEstudiantes EST
		ON EST.EstudianteID = INS.EstudianteID
	INNER JOIN tblTipoEstudiantes TE
		ON EST.TipoEstudianteID = TE.TipoEstudianteID
	INNER JOIN tblSecciones SEC
		ON DI.SeccionID = SEC.SeccionID
	INNER JOIN tblAsignaturas ASIG
		ON ASIG.AsignaturaID = SEC.AsignaturaID
	WHERE 
		EST.EstudianteID = @estudianteID
		AND INS.Inactivo = 0

	RETURN @montoCreditos + @costoInscripcion;
END

GO
/****** Object:  UserDefinedFunction [dbo].[fc_obtenerSecuenciaMatricula]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fc_obtenerSecuenciaMatricula]()
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @secuencia INT;

	SELECT TOP 1
		 @secuencia = Secuencia + 1
	FROM tblSecuenciaMatricula


	RETURN @secuencia

END

GO
/****** Object:  UserDefinedFunction [dbo].[sp_montoPagadoEstudiante]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[sp_montoPagadoEstudiante]
(
	@estudianteID INT
)
RETURNS DECIMAL
AS
BEGIN
	DECLARE @monto DECIMAL
	SET @monto = 0.00;

	SELECT 
		@monto = SUM(MontoAPagar)
	FROM tblPagosEstudiantes
	WHERE
		EstudianteID = @estudianteID

	RETURN CASE WHEN @monto IS NULL THEN 0.00 ELSE @monto END;

END

GO
/****** Object:  Table [dbo].[tblAsignaturas]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblAsignaturas](
	[AsignaturaID] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](100) NOT NULL,
	[CarreraID] [int] NOT NULL,
	[Creditos] [int] NOT NULL,
	[Observaciones] [varchar](max) NULL,
	[Codigo] [varchar](10) NULL,
	[Inactivo] [bit] NOT NULL CONSTRAINT [DF_tblAsignaturas_Inactivo]  DEFAULT ((0)),
 CONSTRAINT [PK_tblAsignaturas] PRIMARY KEY CLUSTERED 
(
	[AsignaturaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblAulas]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblAulas](
	[AulaID] [int] IDENTITY(1,1) NOT NULL,
	[Capacidad] [smallint] NOT NULL CONSTRAINT [DF_tblAulas_Capacidad]  DEFAULT ((25)),
	[Descripcion] [varchar](100) NOT NULL,
	[CentroID] [int] NOT NULL,
	[Observaciones] [varchar](max) NULL,
	[Inactivo] [bit] NULL CONSTRAINT [DF_tblAulas_Inactivo]  DEFAULT ((0)),
 CONSTRAINT [PK_tblAulas] PRIMARY KEY CLUSTERED 
(
	[AulaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblCarreras]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblCarreras](
	[CarreraID] [int] IDENTITY(1000,1) NOT NULL,
	[Descripcion] [varchar](100) NULL,
	[Creditos] [int] NULL,
	[Observaciones] [varchar](max) NULL CONSTRAINT [DF_tblCarreras_Observaciones]  DEFAULT ((0)),
	[Inactivo] [bit] NULL,
 CONSTRAINT [PK_tblCarreras] PRIMARY KEY CLUSTERED 
(
	[CarreraID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblCentros]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblCentros](
	[CentroID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[NombreCorto] [varchar](30) NOT NULL,
	[Descripcion] [varchar](200) NULL,
	[WebSite] [varchar](256) NULL,
	[Telefono] [varchar](20) NULL,
	[Observaciones] [varchar](max) NULL,
	[Inactivo] [bit] NULL CONSTRAINT [DF_tblCentros_Inactivo]  DEFAULT ((0)),
 CONSTRAINT [PK_tblCentros] PRIMARY KEY CLUSTERED 
(
	[CentroID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblDetalleInscripcion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDetalleInscripcion](
	[InscripcionID] [int] NOT NULL,
	[SeccionID] [int] NOT NULL,
	[Inactivo] [bit] NOT NULL CONSTRAINT [DF_tblDetalleInscripcion_Inactivo]  DEFAULT ((0)),
 CONSTRAINT [PK_tblDetalleInscripcion] PRIMARY KEY CLUSTERED 
(
	[InscripcionID] ASC,
	[SeccionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDias]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblDias](
	[DiaID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NULL,
 CONSTRAINT [PK_tblDias] PRIMARY KEY CLUSTERED 
(
	[DiaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblEstudiantes]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblEstudiantes](
	[EstudianteID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](45) NOT NULL,
	[Apellido] [varchar](85) NULL,
	[FechaNacimiento] [date] NOT NULL,
	[Cedula] [varchar](20) NULL,
	[TipoEstudianteID] [int] NULL,
	[Matricula] [varchar](50) NULL,
	[Sexo] [char](1) NULL,
	[EstadoCivil] [char](1) NULL,
	[TelefonoCasa] [varchar](15) NULL,
	[TelefonoMovil] [varchar](15) NULL,
	[Email] [varchar](255) NULL,
	[Observaciones] [varchar](max) NULL,
	[CarreraID] [int] NULL,
	[Balance] [money] NULL CONSTRAINT [DF_tblEstudiantes_Balance]  DEFAULT ((0)),
	[Inactivo] [bit] NULL CONSTRAINT [DF_tblEstudiantes_Inactivo]  DEFAULT ((0)),
 CONSTRAINT [PK__tblEstud__3214EC278008EF90] PRIMARY KEY CLUSTERED 
(
	[EstudianteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblInscripcion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblInscripcion](
	[InscripcionID] [int] IDENTITY(1,1) NOT NULL,
	[EstudianteID] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[Inactivo] [bit] NOT NULL CONSTRAINT [DF_tblInscripcion_Inactivo]  DEFAULT ((0)),
 CONSTRAINT [PK_tblInscripcion] PRIMARY KEY CLUSTERED 
(
	[InscripcionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblPagosEstudiantes]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPagosEstudiantes](
	[PagoID] [int] IDENTITY(1,1) NOT NULL,
	[EstudianteID] [int] NULL,
	[MontoAPagar] [decimal](18, 0) NULL,
	[MontoRecibido] [decimal](18, 0) NULL,
	[Devuelta] [decimal](18, 0) NULL,
 CONSTRAINT [PK_tblPagosEstudiantes] PRIMARY KEY CLUSTERED 
(
	[PagoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProfesores]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblProfesores](
	[ProfesorID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Apellido] [varchar](100) NOT NULL,
	[Cedula] [varchar](20) NOT NULL,
	[Sexo] [char](1) NOT NULL,
	[FechaNacimiento] [date] NOT NULL,
	[EstadoCivil] [char](1) NOT NULL,
	[TelefonoCasa] [varchar](20) NULL,
	[TelefonoMovil] [varchar](20) NULL,
	[Email] [varchar](255) NULL,
	[Observaciones] [varchar](max) NULL,
	[Inactivo] [bit] NULL CONSTRAINT [DF_tblProfesores_Inactivo]  DEFAULT ((0)),
 CONSTRAINT [PK_tblProfesores] PRIMARY KEY CLUSTERED 
(
	[ProfesorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblSecciones]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblSecciones](
	[SeccionID] [int] IDENTITY(1,1) NOT NULL,
	[CentroID] [int] NOT NULL,
	[ProfesorID] [int] NOT NULL,
	[AsignaturaID] [int] NOT NULL,
	[Capacidad] [int] NOT NULL,
	[AulaID] [int] NOT NULL,
	[Dia1ID] [int] NOT NULL,
	[HoraInicioDia1] [time](7) NOT NULL,
	[HoraFinDia1] [time](7) NOT NULL,
	[Dia2ID] [int] NOT NULL,
	[HoraInicioDia2] [time](7) NOT NULL,
	[HoraFinDia2] [time](7) NOT NULL,
	[Observaciones] [varchar](max) NULL,
	[Inactivo] [bit] NULL CONSTRAINT [DF_tblSecciones_Inactivo]  DEFAULT ((0)),
 CONSTRAINT [PK_tblSecciones] PRIMARY KEY CLUSTERED 
(
	[SeccionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblSecuenciaMatricula]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSecuenciaMatricula](
	[Secuencia] [int] NOT NULL,
 CONSTRAINT [PK_tblSecuenciaMatricula] PRIMARY KEY CLUSTERED 
(
	[Secuencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTipoEstudiantes]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblTipoEstudiantes](
	[TipoEstudianteID] [int] IDENTITY(1000,1) NOT NULL,
	[Descripcion] [varchar](100) NOT NULL,
	[CostoCredito] [money] NOT NULL CONSTRAINT [DF_tblTipoEstudiantes_CostoCredito]  DEFAULT ((0)),
	[CostoInscripcion] [money] NOT NULL CONSTRAINT [DF_tblTipoEstudiantes_CostoInscripcion]  DEFAULT ((0)),
	[Observaciones] [varchar](max) NULL,
	[Inactivo] [bit] NOT NULL CONSTRAINT [DF_tblTipoEstudiantes_Inactivo]  DEFAULT ((0)),
 CONSTRAINT [PK_tblTipoEstudiantes] PRIMARY KEY CLUSTERED 
(
	[TipoEstudianteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblTipoUsuario]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblTipoUsuario](
	[TipoUsuarioID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) NULL,
	[Inactivo] [bit] NULL,
	[Permisos] [varchar](max) NULL,
 CONSTRAINT [PK_tblTipoUsuario] PRIMARY KEY CLUSTERED 
(
	[TipoUsuarioID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblUsuarios]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblUsuarios](
	[UsuarioID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) NULL,
	[Usuario] [varchar](50) NULL,
	[Password] [varbinary](512) NULL,
	[TipoUsuarioID] [int] NULL,
	[Observaciones] [varchar](max) NULL,
	[Inactivo] [bit] NULL CONSTRAINT [DF_Usuarios_Inactivo]  DEFAULT ((0)),
 CONSTRAINT [PK__Usuarios__DE4431C5C9DF00DF] PRIMARY KEY CLUSTERED 
(
	[UsuarioID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[tblEstudiantes]  WITH CHECK ADD  CONSTRAINT [FK_tblEstudiantes_tblCarrera] FOREIGN KEY([CarreraID])
REFERENCES [dbo].[tblCarreras] ([CarreraID])
GO
ALTER TABLE [dbo].[tblEstudiantes] CHECK CONSTRAINT [FK_tblEstudiantes_tblCarrera]
GO
/****** Object:  StoredProcedure [dbo].[backupdb]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery2.sql|0|0|C:\Users\Joel\AppData\Local\Temp\~vs1510.sql
CREATE procedure [dbo].[backupdb]
as
BACKUP DATABASE [INF518] TO  DISK =N'C:\copia\test.bak'
WITH NOFORMAT, NOINIT,  NAME = N'test-Completa Base de datos Copia de seguridad', SKIP,NOREWIND, NOUNLOAD,  STATS = 10

GO
/****** Object:  StoredProcedure [dbo].[sp_actualizarAsignatura]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_actualizarAsignatura]
	@asignaturaID INT,
	@descripcion VARCHAR(100),
	@carreraID INT,
	@codigo VARCHAR(10),
	@creditos INT,
	@observaciones VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT OFF;

	UPDATE tblAsignaturas
	SET 
		Descripcion = @descripcion,
		CarreraID = @carreraID,
		Creditos = @creditos,
		Observaciones = @observaciones,
		Codigo = @codigo
	WHERE
		AsignaturaID = @asignaturaID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_actualizarBalanceEstudiante]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_actualizarBalanceEstudiante]
	@estudianteID INT
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE tblEstudiantes
	SET 
		Balance = (dbo.fc_montoEstudiante(@estudianteID) - dbo.sp_montoPagadoEstudiante(@estudianteID))
	WHERE
		EstudianteID = @estudianteID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_actualizarEstudiante]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_actualizarEstudiante]
	@estudianteID INT,
	@nombre VARCHAR(45),
	@apellido varchar(85),
	@fechaNacimiento DATE,
	@cedula VARCHAR(20),
	@tipoEstudianteID INT,
	@sexo CHAR(1),
	@estadoCivil CHAR(1),
	@telefonoCasa VARCHAR(15),
	@telefonoMovil VARCHAR(15),
	@email VARCHAR(100),
	@observaciones VARCHAR(MAX),
	@carreraID INT
AS
BEGIN
	SET NOCOUNT OFF;

	UPDATE tblEstudiantes
	SET 
		Nombre = @nombre,
		Apellido = @apellido,
		FechaNacimiento = @fechaNacimiento,
		Cedula = @cedula,
		TipoEstudianteID = @tipoEstudianteID,
		Sexo = @sexo,
		EstadoCivil = @estadoCivil,
		TelefonoCasa = @telefonoCasa,
		TelefonoMovil = @telefonoMovil,
		Email = @email,
		Observaciones = @observaciones,
		CarreraID = @carreraID
	WHERE
		EstudianteID = @estudianteID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_actualizarProfesor]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_actualizarProfesor]
	@profesorID INT,
	@nombre VARCHAR(50),
	@apellido VARCHAR(100),
	@cedula VARCHAR(20),
	@sexo VARCHAR(1),
	@fechaNacimiento DATE,
	@estadoCivil CHAR(1),
	@telefonoCasa VARCHAR(20),
	@telefonoMovil VARCHAR(20),
	@email VARCHAR(255),
	@observaciones VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT OFF;

	UPDATE tblProfesores
	SET 
		Nombre = @nombre,
		Apellido = @apellido,
		Cedula = @cedula,
		Sexo = @sexo,
		FechaNacimiento = @fechaNacimiento,
		EstadoCivil = @estadoCivil,
		TelefonoCasa = @telefonoCasa,
		TelefonoMovil = @telefonoMovil,
		Email = @email,
		Observaciones = @observaciones
	WHERE
		ProfesorID = @profesorID
END

GO
/****** Object:  StoredProcedure [dbo].[sp_actualizarSeccion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_actualizarSeccion]
	@seccionID INT,
	@centroID INT,
	@profesorID INT,
	@asignaturaID INT,
	@capacidad INT,
	@aulaID INT,
	@dia1ID INT,
	@dia2ID INT,
	@HoraInicioDia1 TIME,
	@HoraFinDia1 TIME,
	@HoraInicioDia2 TIME,
	@HoraFinDia2 TIME,
	@observaciones VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT OFF;
	UPDATE tblSecciones
	SET
		CentroID = @centroID,
		ProfesorID = @profesorID,
		AsignaturaID = @asignaturaID,
		Capacidad = @capacidad,
		AulaID = @aulaID,
		Dia1ID = @dia1ID,
		HoraInicioDia1 = @HoraInicioDia1,
		HoraFinDia1 = @HoraFinDia1,
		Dia2ID = @dia2ID,
		HoraInicioDia2 = @HoraInicioDia2,
		HoraFinDia2 = @HoraFinDia2,
		Observaciones = @observaciones
	WHERE
		SeccionID = @seccionID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_actualizarUsuario]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_actualizarUsuario]
	@usuarioID INT,
	@nombre varchar(100),
	@nombreUsuario varchar(50),
	@tipoUsuarioID int,
	@observaciones varchar(MAX)
AS
BEGIN
	SET NOCOUNT OFF;
	UPDATE tblUsuarios
	SET 
		Nombre = @nombre,
		Usuario = @nombreUsuario,
		TipoUsuarioID = @tipoUsuarioID,
		Observaciones = @observaciones
	WHERE
		UsuarioID = @usuarioID
END

GO
/****** Object:  StoredProcedure [dbo].[sp_agregarSeccionAInscripcion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_agregarSeccionAInscripcion]
	@inscripcionID INT,
	@seccionID INT
AS
BEGIN
	SET NOCOUNT OFF;
	DECLARE @estudianteID INT;

	SELECT 
		@estudianteID = EstudianteID 
		FROM 
			tblInscripcion 
		WHERE 
			InscripcionID = @inscripcionID;

	INSERT INTO tblDetalleInscripcion(
		InscripcionID,
		SeccionID
	)VALUES(
		@inscripcionID,
		@seccionID
	);

	EXEC sp_actualizarBalanceEstudiante @estudianteID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_buscarAsignaturas]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_buscarAsignaturas]
	@busqueda VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		AsignaturaID,
		Descripcion,
		Codigo
	FROM tblAsignaturas
	WHERE 
		Descripcion LIKE '%' + @busqueda + '%'
		OR Codigo LIKE '%' + @busqueda + '%'
END

GO
/****** Object:  StoredProcedure [dbo].[sp_buscarAulas]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_buscarAulas]
	@busqueda VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		A.AulaID,
		A.Descripcion,
		C.Nombre AS 'Centro'
	FROM tblAulas A
	INNER JOIN tblCentros C
		ON C.CentroID = A.CentroID
	WHERE 
		A.Descripcion LIKE '%' + @busqueda + '%'
		OR C.Nombre LIKE  '%' + @busqueda + '%'
END

GO
/****** Object:  StoredProcedure [dbo].[sp_buscarCarreras]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_buscarCarreras]
	@busqueda VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		CarreraID,
		Descripcion,
		Creditos
	FROM tblCarreras	
	WHERE
		Descripcion LIKE '%' + @busqueda +'%'
END

GO
/****** Object:  StoredProcedure [dbo].[sp_buscarCentros]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_buscarCentros]
	@busqueda VARCHAR(100)
AS
BEGIN
	SELECT 
		CentroID,
		Nombre,
		NombreCorto
	FROM tblCentros
	WHERE
		Nombre LIKE '%' + @busqueda +'%'
		OR NombreCorto LIKE '%' + @busqueda +'%'
END

GO
/****** Object:  StoredProcedure [dbo].[sp_buscarEstudiantes]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_buscarEstudiantes]
	@busqueda VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;


	SELECT 
		EstudianteID,
		Matricula,
		Nombre,
		Apellido,
		Cedula
	FROM tblEstudiantes
	WHERE 
		Nombre LIKE '%' + @busqueda+'%'
		OR Apellido LIKE '%' + @busqueda+'%'
		OR Cedula LIKE '%' + @busqueda+'%'
		OR Matricula LIKE '%' + @busqueda+'%'
END

GO
/****** Object:  StoredProcedure [dbo].[sp_buscarProfesores]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_buscarProfesores]
	@busqueda VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		ProfesorID,
		Nombre + ' ' + Apellido AS 'Nombre',
		Cedula
	FROM tblProfesores
	WHERE
		Inactivo = 0
		AND 
		(
			Nombre LIKE '%'+ @busqueda +'%'
			OR Apellido LIKE '%'+ @busqueda +'%'
			OR Cedula LIKE '%'+ @busqueda +'%'
		)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_buscarSecciones]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_buscarSecciones]
	@asignaturaID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		S.SeccionID,
		P.Nombre + ' ' + P.Apellido AS 'Profesor',
		D1.Nombre AS 'Dia1',
		CONVERT(VARCHAR,S.HoraInicioDia1,0) AS 'HoraInicioDia1',
		CONVERT(VARCHAR,S.HoraFinDia1,0) AS 'HoraFinDia1',
		D2.Nombre AS 'Dia2',
		CONVERT(VARCHAR,S.HoraInicioDia2,0) AS 'HoraInicioDia2',
		CONVERT(VARCHAR,S.HoraFinDia2,0) AS 'HoraFinDia2'
	FROM tblSecciones S
	INNER JOIN tblProfesores P
		ON P.ProfesorID = S.ProfesorID
	INNER JOIN tblDias D1
		ON D1.DiaID = S.Dia1ID
	INNER JOIN tblDias D2
		ON D2.DiaID = S.Dia2ID
	WHERE
		S.AsignaturaID = @asignaturaID
END

GO
/****** Object:  StoredProcedure [dbo].[sp_buscarTiposUsuarios]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_buscarTiposUsuarios]
AS
BEGIN
	SELECT
		TipoUsuarioID,
		Nombre
	FROM tblTipoUsuario
END

GO
/****** Object:  StoredProcedure [dbo].[sp_buscarUsuarios]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_buscarUsuarios]
	@busqueda VARCHAR(MAX)
AS
BEGIN

	SET NOCOUNT ON;
	SELECT
		U.UsuarioID, 
		U.Nombre,
		U.Usuario,
		TU.Nombre AS 'TipoUsuario'
	FROM tblUsuarios U
	INNER JOIN tblTipoUsuario TU
		ON TU.TipoUsuarioID = U.TipoUsuarioID
	WHERE
		U.Nombre LIKE '%' + @busqueda + '%'
		OR U.Usuario LIKE '%' + @busqueda + '%'
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cambiarPasswordUsario]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_cambiarPasswordUsario]
	@usuarioID INT,
	@password VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT OFF;
	UPDATE tblUsuarios
	SET 
		Password = PWDENCRYPT(@password)
	WHERE
		UsuarioID = @usuarioID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_crearAsignatura]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_crearAsignatura]
	@descripcion VARCHAR(100),
	@carreraID INT,
	@codigo VARCHAR(10),
	@creditos INT,
	@observaciones VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT OFF;

	INSERT INTO tblAsignaturas(
		Descripcion,
		CarreraID,
		Creditos,
		Codigo,
		Observaciones
	)VALUES(
		@descripcion,
		@carreraID,
		@creditos,
		@codigo,
		@observaciones
	)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_crearAula]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_crearAula]
	@descripcion VARCHAR(100),
	@capacidad SMALLINT,
	@centroID INT,
	@observaciones VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT OFF;

	INSERT INTO tblAulas(
		Descripcion,
		Capacidad,
		CentroID,
		Observaciones
	)VALUES(
	
		@descripcion,
		@capacidad,
		@centroId,
		@observaciones
	)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_crearCarrera]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_crearCarrera]
	@descripcion VARCHAR(100),
	@creditos INT,
	@observaciones VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT OFF;

	INSERT INTO tblCarreras(
		Descripcion,
		Creditos,
		Observaciones
	)VALUES(
		@descripcion,
		@creditos,
		@observaciones
	)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_crearCentro]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_crearCentro]
	@nombre VARCHAR(100),
	@nombreCorto VARCHAR(30),
	@webSite VARCHAR(256),
	@telefono VARCHAR(20),
	@observaciones VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT OFF;
	
	INSERT INTO tblCentros(
		Nombre,
		NombreCorto,
		WebSite,
		Telefono,
		Observaciones
	)VALUES(
		@nombre,
		@nombreCorto,
		@webSite,
		@telefono,
		@observaciones
	)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_crearEstudiante]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_crearEstudiante]
	@nombre VARCHAR(45),
	@apellido varchar(85),
	@fechaNacimiento DATE,
	@cedula VARCHAR(20),
	@tipoEstudianteID INT,
	@matricula VARCHAR(50),
	@sexo CHAR(1),
	@estadoCivil CHAR(1),
	@telefonoCasa VARCHAR(15),
	@telefonoMovil VARCHAR(15),
	@email VARCHAR(100),
	@observaciones VARCHAR(MAX),
	@carreraID INT
AS
BEGIN
	SET NOCOUNT OFF;

	INSERT INTO tblEstudiantes(
		[Nombre],
		[Apellido],
		[FechaNacimiento],
		[Cedula],
		[TipoEstudianteID],
		[Matricula],
		[Sexo],
		[EstadoCivil],
		[TelefonoCasa],
		[TelefonoMovil],
		[Email],
		[Observaciones],
		[CarreraID]
	)VALUES(
		@nombre,
		@apellido,
		@fechaNacimiento,
		@cedula,
		@tipoEstudianteID,
		@matricula,
		@sexo,
		@estadoCivil,
		@telefonoCasa,
		@telefonoMovil,
		@email,
		@observaciones,
		@carreraID
	)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_crearProfesor]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_crearProfesor]
	@nombre VARCHAR(50),
	@apellido VARCHAR(100),
	@cedula VARCHAR(20),
	@sexo VARCHAR(1),
	@fechaNacimiento DATE,
	@estadoCivil CHAR(1),
	@telefonoCasa VARCHAR(20),
	@telefonoMovil VARCHAR(20),
	@email VARCHAR(255),
	@observaciones VARCHAR(MAX)
AS
BEGIN

	SET NOCOUNT OFF;

	INSERT INTO tblProfesores(
		Nombre,
		Apellido,
		Cedula,
		Sexo,
		FechaNacimiento,
		EstadoCivil,
		TelefonoCasa,
		TelefonoMovil,
		Email,
		Observaciones
	)VALUES(
		@nombre,
		@apellido,
		@cedula,
		@sexo,
		@fechaNacimiento,
		@estadoCivil,
		@telefonoCasa,
		@telefonoMovil,
		@email,
		@observaciones
	)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_crearSeccion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_crearSeccion]
	@centroID INT,
	@profesorID INT,
	@asignaturaID INT,
	@capacidad INT,
	@aulaID INT,
	@dia1ID INT,
	@dia2ID INT,
	@HoraInicioDia1 TIME,
	@HoraFinDia1 TIME,
	@HoraInicioDia2 TIME,
	@HoraFinDia2 TIME,
	@observaciones VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

	INSERT INTO tblSecciones(
		CentroID,
		ProfesorID,
		AsignaturaID,
		Capacidad,
		AulaID,
		Dia1ID,
		Dia2ID,
		HoraInicioDia1,
		HoraFinDia1,
		HoraInicioDia2,
		HoraFinDia2,
		Observaciones
	)VALUES (
		@centroID,
		@profesorID,
		@asignaturaID,
		@capacidad,
		@aulaID,
		@dia1ID,
		@dia2ID,
		@HoraInicioDia1,
		@HoraFinDia1,
		@HoraInicioDia2,
		@HoraFinDia2,
		@observaciones
	)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_crearUsuario]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
CREATE PROCEDURE [dbo].[sp_crearUsuario]
	@nombre varchar(100),
	@password varchar(50),
	@nombreUsuario varchar(50),
	@tipoUsuarioID int,
	@observaciones varchar(MAX)
AS
BEGIN
	SET NOCOUNT OFF;
	INSERT INTO tblUsuarios(
		Nombre,
		Usuario,
		Password,
		TipoUsuarioID,
		Observaciones
	)VALUES(
		@nombre,
		@nombreUsuario,
		PWDENCRYPT(@password),
		@tipoUsuarioID,
		@observaciones
	)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_detalleAsignatura]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_detalleAsignatura]
	@asignaturaID INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		AsignaturaID,
		Descripcion,
		CarreraID,
		Creditos,
		Observaciones,
		Codigo
	FROM tblAsignaturas
	WHERE 
		AsignaturaID = @asignaturaID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_detalleAula]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_detalleAula]
	@aulaID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT 
		Capacidad,
		Descripcion,
		CentroID,
		Observaciones
	FROM tblAulas
	WHERE 
		AulaID = @aulaID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_detalleEstudiante]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_detalleEstudiante]
	@estudianteID INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		E.Nombre,
		E.Apellido,
		E.FechaNacimiento,
		E.Cedula,
		E.TipoEstudianteID,
		E.Matricula,
		E.Sexo,
		E.EstadoCivil,
		E.TelefonoCasa,
		E.TelefonoMovil,
		E.Email,
		E.Observaciones,
		E.CarreraID,
		E.Balance
	FROM tblEstudiantes E
	WHERE
		E.EstudianteID = @estudianteID;

END

GO
/****** Object:  StoredProcedure [dbo].[sp_detalleInscripcion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_detalleInscripcion]
	@inscripcionID INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		EstudianteID,
		Fecha
	FROM tblInscripcion
	WHERE
		InscripcionID = @inscripcionID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_detalleProfesor]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_detalleProfesor]
	@profesorID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Nombre,
		Apellido,
		Cedula,
		Sexo,
		FechaNacimiento,
		EstadoCivil,
		TelefonoCasa,
		TelefonoMovil,
		Email,
		Observaciones
	FROM tblProfesores
	WHERE 
		ProfesorID = @profesorID
END

GO
/****** Object:  StoredProcedure [dbo].[sp_detalleSeccion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_detalleSeccion]
	@seccionID INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		S.SeccionID,
		S.CentroID,
		S.ProfesorID,
		S.AsignaturaID,
		S.Capacidad,
		S.AulaID,
		S.Dia1ID,
		S.HoraInicioDia1,
		S.HoraFinDia1,
		S.Dia2ID,
		S.HoraInicioDia2,
		S.HoraFinDia2,
		S.Observaciones
	FROM tblSecciones S
	WHERE
		S.SeccionID = @seccionID
END

GO
/****** Object:  StoredProcedure [dbo].[sp_detalleUsuario]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_detalleUsuario]
	@usuarioID INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		Nombre,
		Usuario,
		TipoUsuarioID,
		Observaciones
	FROM tblUsuarios
	WHERE
		UsuarioID = @usuarioID
END

GO
/****** Object:  StoredProcedure [dbo].[sp_eliminarSeccionInscripcion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_eliminarSeccionInscripcion]
	@seccionID INT,
	@inscripcionID INT
AS
BEGIN
	SET NOCOUNT OFF;
	DELETE FROM tblDetalleInscripcion
	WHERE
		SeccionID = @seccionID
		AND InscripcionID = @inscripcionID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listadoAulasPorCentro]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_listadoAulasPorCentro]
	@centroID INT
AS
BEGIN

	SET NOCOUNT OFF;

	SELECT 
		AulaID,
		Descripcion
	FROM tblAulas
	WHERE
		CentroID = @centroID
		AND Inactivo = 0
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listadoDias]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_listadoDias]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		DiaID,
		Nombre
	FROM tblDias
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listadoSeccionesInscripcion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_listadoSeccionesInscripcion]
	@inscripcionID INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		SEC.SeccionID,
		ASIG.Descripcion AS 'Asignatura',
		A.Descripcion AS 'Aula',
		D1.Nombre AS 'Dia1',
		CONVERT(VARCHAR,SEC.HoraInicioDia1,0) AS 'HoraInicioDia1',
		CONVERT(VARCHAR,SEC.HoraFinDia1,0) AS 'HoraFinDia1',
		D2.Nombre AS 'Dia2',
		CONVERT(VARCHAR,SEC.HoraInicioDia2,0) AS 'HoraInicioDia2',
		CONVERT(VARCHAR,SEC.HoraFinDia2,0) AS 'HoraFinDia2'
	FROM tblDetalleInscripcion DI
	INNER JOIN tblSecciones SEC
		ON SEC.SeccionID = DI.SeccionID
	INNER JOIN tblAsignaturas ASIG
		ON ASIG.AsignaturaID = SEC.AsignaturaID
	INNER JOIN tblDias D1
		ON SEC.Dia1ID = D1.DiaID
	INNER JOIN tblDias D2
		ON SEC.Dia2ID = D2.DiaID
	INNER JOIN tblAulas A
		ON A.AulaID = SEC.AulaID
	WHERE
		DI.InscripcionID = @inscripcionID
END

GO
/****** Object:  StoredProcedure [dbo].[sp_listadoTipoEstudiante]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE  [dbo].[sp_listadoTipoEstudiante]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT  
		TipoEstudianteID,
		Descripcion 
	FROM tblTipoEstudiantes 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_matricularEstudiante]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_matricularEstudiante]
	@nombre VARCHAR(45),
	@apellido varchar(85),
	@fechaNacimiento DATE,
	@cedula VARCHAR(20),
	@tipoEstudianteID INT,
	@sexo CHAR(1),
	@estadoCivil CHAR(1),
	@telefonoCasa VARCHAR(15),
	@telefonoMovil VARCHAR(15),
	@email VARCHAR(100),
	@observaciones VARCHAR(MAX),
	@carreraID INT
AS
BEGIN
	SET NOCOUNT OFF;

	INSERT INTO tblEstudiantes(
		[Nombre],
		[Apellido],
		[FechaNacimiento],
		[Cedula],
		[TipoEstudianteID],
		[Matricula],
		[Sexo],
		[EstadoCivil],
		[TelefonoCasa],
		[TelefonoMovil],
		[Email],
		[Observaciones],
		[CarreraID]
	)VALUES(
		@nombre,
		@apellido,
		@fechaNacimiento,
		@cedula,
		@tipoEstudianteID,
		('E-'  + RIGHT('0000000000000' + CONVERT(VARCHAR,dbo.fc_obtenerSecuenciaMatricula()), 6)),
		@sexo,
		@estadoCivil,
		@telefonoCasa,
		@telefonoMovil,
		@email,
		@observaciones,
		@carreraID
	)

	UPDATE tblSecuenciaMatricula SET Secuencia = Secuencia + 1;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_registrarInscripcion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_registrarInscripcion]
	@estudianteID INT
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO tblInscripcion(
		EstudianteID,
		Fecha
	)VALUES(
		@estudianteID,
		GETDATE()
	);

	SELECT SCOPE_IDENTITY() AS 'ID';
END

GO
/****** Object:  StoredProcedure [dbo].[sp_registrarPagoEstudiante]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_registrarPagoEstudiante]
	@estudianteID INT,
	@montoAPagar DECIMAL,
	@montoRecibido DECIMAL,
	@devuelta DECIMAL
AS
BEGIN
	SET NOCOUNT OFF;

	INSERT INTO tblPagosEstudiantes(
		EstudianteID,
		MontoAPagar,
		MontoRecibido,
		Devuelta
	)VALUES(
		@estudianteID,
		@montoAPagar,
		@montoRecibido,
		@devuelta
	)

	exec [sp_actualizarBalanceEstudiante] @estudianteID;
END

GO
/****** Object:  StoredProcedure [dbo].[sp_validarLogin]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_validarLogin]
	@usuario varchar(50),
	@password varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		U.UsuarioID,
		U.Nombre,
		U.Usuario,
		TU.Permisos,
		TU.Nombre AS 'TipoUsuario'
	FROM tblUsuarios U
	INNER JOIN tblTipoUsuario TU
		ON U.TipoUsuarioID = TU.TipoUsuarioID
	WHERE
		Usuario = @usuario
		AND PWDCOMPARE(@password,Password) = 1 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_verificarAsignaturaInscripcion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_verificarAsignaturaInscripcion]
	@inscripcionID INT,
	@asignaturaID INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		DI.SeccionID
	FROM tblDetalleInscripcion DI
	INNER JOIN tblSecciones SEC
		ON DI.SeccionID = SEC.SeccionID
	WHERE
		DI.InscripcionID = @inscripcionID
		AND SEC.AsignaturaID = @asignaturaID		
END

GO
/****** Object:  StoredProcedure [dbo].[sp_verificarConflictosAula]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_verificarConflictosAula]
	@seccionID INT,
	@aulaID INT,
	@dia1 INT,
	@horaInicioDia1 TIME,
	@horaFinDia1 TIME,
	@dia2 INT,
	@horaInicioDia2 TIME,
	@horaFinDia2 TIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		S.SeccionID,
		ASIG.Descripcion AS 'Asignatura',
		A.Descripcion AS 'Aula',
		D1.Nombre AS 'Dia1',
		S.HoraInicioDia1,
		S.HoraFinDia1,
		D2.Nombre AS 'Dia2',
		S.HoraInicioDia2,
		S.HoraFinDia2
	FROM tblAulas A
	INNER JOIN tblSecciones S
		ON S.AulaID = A.AulaID
	INNER JOIN tblDias D1
		ON D1.DiaID = S.Dia1ID
	INNER JOIN tblDias D2
		ON D2.DiaID = S.Dia2ID
	INNER JOIN tblAsignaturas ASIG
		ON ASIG.AsignaturaID = S.AsignaturaID
	WHERE
		S.AulaID = @aulaID
		AND
		(
			(
				S.Dia1ID = @dia1
				AND (S.HoraInicioDia1 BETWEEN  @horaInicioDia1 AND @horaFinDia1 OR  S.HoraFinDia1 BETWEEN @horaInicioDia1 AND @horaFinDia1)

			)OR
			(
				S.Dia2ID = @dia1
				AND (S.HoraInicioDia2 BETWEEN  @horaInicioDia1 AND @horaFinDia1 OR  S.HoraFinDia2 BETWEEN @horaInicioDia1 AND @horaFinDia1)
			)
		)
		AND S.SeccionID <> @seccionID
	UNION 
	SELECT 
		S.SeccionID,
		ASIG.Descripcion AS 'Asignatura',
		A.Descripcion AS 'Aula',
		D1.Nombre AS 'Dia1',
		S.HoraInicioDia1,
		S.HoraFinDia1,
		D2.Nombre AS 'Dia2',
		S.HoraInicioDia2,
		S.HoraFinDia2
	FROM tblAulas A
	INNER JOIN tblSecciones S
		ON S.AulaID = A.AulaID
	INNER JOIN tblDias D1
		ON D1.DiaID = S.Dia1ID
	INNER JOIN tblDias D2
		ON D2.DiaID = S.Dia2ID
	INNER JOIN tblAsignaturas ASIG
		ON ASIG.AsignaturaID = S.AsignaturaID
	WHERE
		S.AulaID = @aulaID
		AND 
		(
			(
				S.Dia1ID = @dia2
				AND 
					(S.HoraInicioDia2 BETWEEN  @horaInicioDia2 AND @horaFinDia2 OR  S.HoraFinDia2 BETWEEN @horaInicioDia2 AND @horaFinDia2)

			)OR
			(
				S.Dia2ID = @dia2
				AND 
					(S.HoraInicioDia2 BETWEEN  @horaInicioDia2 AND @horaFinDia2 OR  S.HoraFinDia2 BETWEEN @horaInicioDia2 AND @horaFinDia2)
			)
		)
		AND S.SeccionID <> @seccionID
END

GO
/****** Object:  StoredProcedure [dbo].[sp_verificarConflictosHorariosInscripcion]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_verificarConflictosHorariosInscripcion]
	@inscripcionID INT,
	@seccionID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @dia1 INT;
	DECLARE @horaInicioDia1 TIME;
	DECLARE @horaFinDia1 TIME;
	DECLARE @dia2 INT;
	DECLARE @horaInicioDia2 TIME;
	DECLARE @horaFinDia2 TIME;

	SELECT
		@dia1 = Dia1ID,
		@horaInicioDia1 = HoraInicioDia1,
		@horaFinDia1 = HoraFinDia1,
		@dia2 = Dia2ID,
		@horaInicioDia2 = HoraInicioDia2,
		@horaFinDia2 = HoraFinDia2
	FROM tblSecciones 
	WHERE 
		SeccionID = @seccionID

	SELECT 
		SEC.SeccionID,
		A.Descripcion AS 'Aula',
		ASIG.Descripcion AS 'Asignatura',
		D1.Nombre AS 'Dia1',
		CONVERT(VARCHAR,SEC.HoraInicioDia1,0) AS 'HoraInicioDia1',
		CONVERT(VARCHAR,SEC.HoraFinDia1,0) AS 'HoraFinDia1',
		D2.Nombre AS 'Dia2',
		CONVERT(VARCHAR,SEC.HoraInicioDia2,0) AS 'HoraInicioDia2',
		CONVERT(VARCHAR,SEC.HoraFinDia2,0) AS 'HoraFinDia2'
	FROM tblSecciones SEC
	INNER JOIN tblDetalleInscripcion DI
		ON SEC.SeccionID = DI.SeccionID
	INNER JOIN tblDias D1
		ON SEC.Dia1ID = D1.DiaID
	INNER JOIN tblDias D2
		ON SEC.Dia2ID = D2.DiaID
	INNER JOIN tblAsignaturas ASIG
		ON SEC.AsignaturaID = ASIG.AsignaturaID
	INNER JOIN tblAulas A
		ON SEC.AulaID = A.AulaID
	WHERE
		DI.InscripcionID = @inscripcionID
		AND 
		(
			(
				SEC.Dia1ID = @dia1
				AND (SEC.HoraInicioDia1 BETWEEN @horaInicioDia1 AND @horaFinDia1 OR SEC.HoraFinDia1 BETWEEN @horaInicioDia1 AND @horaFinDia1)
			)
			OR 
			(
				SEC.Dia1ID = @dia2
				AND (SEC.HoraInicioDia1 BETWEEN @horaInicioDia2 AND @horaFinDia2 OR SEC.HoraFinDia1 BETWEEN @horaInicioDia2 AND @horaFinDia2)
			)
			OR
			(
				SEC.Dia2ID = @dia1
				AND (SEC.HoraInicioDia2 BETWEEN @horaInicioDia1 AND @horaFinDia1 OR SEC.HoraFinDia2 BETWEEN @horaInicioDia1 AND @horaFinDia1)
			)
			OR 
			(
				SEC.Dia2ID = @dia2
				AND (SEC.HoraInicioDia2 BETWEEN @horaInicioDia2 AND @horaFinDia2 OR SEC.HoraFinDia2 BETWEEN @horaInicioDia2 AND @horaFinDia2)
			)
		)
		AND SEC.SeccionID <> @seccionID

END

GO
/****** Object:  StoredProcedure [dbo].[sp_verificarConflictosProfesor]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_verificarConflictosProfesor]
	@seccionID INT,
	@profesorID INT,
	@dia1 INT,
	@horaInicioDia1 TIME,
	@horaFinDia1 TIME,
	@dia2 INT,
	@horaInicioDia2 TIME,
	@horaFinDia2 TIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		S.SeccionID,
		ASIG.Descripcion AS 'Asignatura',
		A.Descripcion AS 'Aula',
		D1.Nombre AS 'Dia1',
		S.HoraInicioDia1,
		S.HoraFinDia1,
		D2.Nombre AS 'Dia2',
		S.HoraInicioDia2,
		S.HoraFinDia2
	FROM tblSecciones S
	INNER JOIN tblAulas A 
		ON A.AulaID = S.AulaID
	INNER JOIN tblDias D1
		ON D1.DiaID = S.Dia1ID
	INNER JOIN tblDias D2
		ON D2.DiaID = S.Dia2ID
	INNER JOIN tblAsignaturas ASIG
		ON ASIG.AsignaturaID = S.AsignaturaID
	WHERE
		S.AulaID = @profesorID
		AND
		(
			(
				S.Dia1ID = @dia1
				AND (S.HoraInicioDia1 BETWEEN  @horaInicioDia1 AND @horaFinDia1 OR  S.HoraFinDia1 BETWEEN @horaInicioDia1 AND @horaFinDia1)

			)OR
			(
				S.Dia2ID = @dia1
				AND (S.HoraInicioDia2 BETWEEN  @horaInicioDia1 AND @horaFinDia1 OR  S.HoraFinDia2 BETWEEN @horaInicioDia1 AND @horaFinDia1)
			)
		)
		AND S.SeccionID <> @seccionID
	UNION 
	SELECT 
		S.SeccionID,
		ASIG.Descripcion AS 'Asignatura',
		A.Descripcion AS 'Aula',
		D1.Nombre AS 'Dia1',
		S.HoraInicioDia1,
		S.HoraFinDia1,
		D2.Nombre AS 'Dia2',
		S.HoraInicioDia2,
		S.HoraFinDia2
	FROM tblSecciones S
	INNER JOIN tblAulas A 
		ON A.AulaID = S.AulaID
	INNER JOIN tblDias D1
		ON D1.DiaID = S.Dia1ID
	INNER JOIN tblDias D2
		ON D2.DiaID = S.Dia2ID
	INNER JOIN tblAsignaturas ASIG
		ON ASIG.AsignaturaID = S.AsignaturaID
	WHERE
		S.AulaID = @profesorID
		AND 
		(
			(
				S.Dia1ID = @dia2
				AND 
					(S.HoraInicioDia2 BETWEEN  @horaInicioDia2 AND @horaFinDia2 OR  S.HoraFinDia2 BETWEEN @horaInicioDia2 AND @horaFinDia2)

			)OR
			(
				S.Dia2ID = @dia2
				AND 
					(S.HoraInicioDia2 BETWEEN  @horaInicioDia2 AND @horaFinDia2 OR  S.HoraFinDia2 BETWEEN @horaInicioDia2 AND @horaFinDia2)
			)
		)
		AND S.SeccionID <> @seccionID
END

GO
/****** Object:  StoredProcedure [dbo].[sp_verificarInscipcionExistente]    Script Date: 19/7/2019 8:16:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_verificarInscipcionExistente]
	@estudianteID INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		InscripcionID,
		EstudianteID,
		Fecha
	FROM tblInscripcion
	WHERE
		Inactivo = 0
		AND EstudianteID = @estudianteID
END

GO
USE [master]
GO
ALTER DATABASE [INF518] SET  READ_WRITE 
GO
