import 'package:get/get.dart';

// Define the translation class
class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'Home': 'Home',
      'Products': 'Products',
      'Orders': 'Orders',
      'AI Service': 'AI Service',
      'Customization': 'Customization',
      'Language': 'Language',
      'Logout': 'Logout',
    },
    'hi': {
      'Home': 'घर',
      'Products': 'उत्पाद',
      'Orders': 'आदेश',
      'AI Service': 'ए.आई. सेवा',
      'Customization': 'कस्टमाइज़ेशन',
      'Language': 'भाषा',
      'Logout': 'लॉगआउट',
    },
    'fr': {
      'Home': 'Accueil',
      'Products': 'Produits',
      'Orders': 'Commandes',
      'AI Service': 'Service IA',
      'Customization': 'Personnalisation',
      'Language': 'Langue',
      'Logout': 'Se déconnecter',
    },
    'es': {
      'Home': 'Inicio',
      'Products': 'Productos',
      'Orders': 'Pedidos',
      'AI Service': 'Servicio de IA',
      'Customization': 'Personalización',
      'Language': 'Idioma',
      'Logout': 'Cerrar sesión',
    },
    'de': {
      'Home': 'Startseite',
      'Products': 'Produkte',
      'Orders': 'Bestellungen',
      'AI Service': 'KI-Dienst',
      'Customization': 'Anpassung',
      'Language': 'Sprache',
      'Logout': 'Ausloggen',
    },
  };
}
