class Env {
  static bool isGalleryActive = false;

  //Funciones de utilidad que nos permiten anidar proyectos de flutter dentro de una aplicación principal,
  //sin romper fuentes/activos de imagen.
//Para facilitar esto, el valor del paquete debe ser nulo cuando se usa en el proyecto principal,
//pero no nulo cuando se usa desde la aplicación principal.
  static String? getPackage(String value) => isGalleryActive ? value : null;
  static String getBundle(String value) => "packages/$value";

/**
 * USAGE
		//In main App() class
		static String _pkg = "constellations_list";
		static String get pkg => Env.getPackage(_pkg);
		static String get bundle => Env.getBundle(_pkg);

		//Anywhere in app
		TextStyle(fontFamily: "Poppins", package: App.pkg);
		Image.asset("images/logo.png", package: App.pkg);
		rootBundle.load('${App.bundle}/assets/glow.png')
		
	IMPORTANT: If using rootBundle.load(), there's 2 additional steps:
		1. Move your assets into /lib, for example /lib/images/img.png
		2. Include the assets in pubspec.yaml, using the package syntax:
		   /packages/mypackagename/images/img.png

		Note: You only have to do this for assets that are loaded with rootBundle(), the rest can stay in the root directory of your project
 */
}
