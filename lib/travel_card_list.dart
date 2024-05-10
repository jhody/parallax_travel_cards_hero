import 'package:flutter/material.dart';
import 'package:parallax_travel_cards_hero/models/city.dart';
import 'package:parallax_travel_cards_hero/shared/rotation_3d.dart';
import 'package:parallax_travel_cards_hero/travel_card_renderer.dart';

class TravelCardList extends StatefulWidget {
  final List<City> cities;
  final Function onCityChange;

  const TravelCardList(
      {Key? key, required this.cities, required this.onCityChange})
      : super(key: key);

  @override
  TravelCardListState createState() => TravelCardListState();
}

class TravelCardListState extends State<TravelCardList>
    with SingleTickerProviderStateMixin {
  final double _maxRotation = 20;

  PageController? _pageController;

  double _cardWidth = 160;
  double _cardHeight = 200;
  double _normalizedOffset = 0;
  double _prevScrollX = 0;
  bool _isScrolling = false;
  //int _focusedIndex = 0;

  //Crear controlador, que inicia/detiene la interpolación y reconstruye este widget mientras se ejecuta
  late AnimationController _tweenController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
  //Create Tween, Crear interpolación, que define nuestros valores de inicio + fin.
  Tween<double> _tween = Tween<double>(begin: -1, end: 0);
  //Crear animación, que nos permite acceder al valor de interpolación actual y a la devolución de llamada onUpdate().
  late Animation<double> _tweenAnim = _tween.animate(
    new CurvedAnimation(parent: _tweenController, curve: Curves.elasticOut),
  );
  @override
  void initState() {
    //Establecer nuestro desplazamiento cada vez que la interpolación se actualiza
    _tweenAnim.addListener(() => _setOffset(_tweenAnim.value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _cardHeight = (size.height * .48)
        .clamp(300.0, 400.0); // con clamp no sobrepasa estos valores
    _cardWidth = _cardHeight * .8;
    //Calcule la fracción de viewPort para esta relación de aspecto, ya que PageController no acepta valores de tamaño basados ​​en píxeles
    _pageController = PageController(
        initialPage: 1, viewportFraction: _cardWidth / size.width);

    //Create our main list
    Widget listContent = Container(
      //Envuelva la lista en un contenedor para controlar la altura y el relleno
      height: _cardHeight,
      //Utilice un ListView.builder, llame a buildItemRenderer() de forma perezosa, siempre que necesite mostrar un listItem
      child: PageView.builder(
        //Use bounce-style scroll physics, se siente mejor con esta demostración
        physics: BouncingScrollPhysics(),
        controller: _pageController,
        itemCount: 8,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => _buildRotatedTravelCard(i),
      ),
    );

    //Envuelva el contenido de nuestra lista en un Listener para detectar eventos PointerUp y un NotificationListener para detectar ScrollStart y ScrollUpdate.
    //Tenemos que usar ambos, porque NotificationListener no nos informa cuando el usuario ha levantado el dedo.
    //No podemos usar GestureDetector como lo haríamos normalmente, ListView lo suprime mientras nos desplazamos.
    return Listener(
      onPointerUp: _handlePointerUp,
      child: NotificationListener(
        onNotification: _handleScrollNotifications,
        child: listContent,
      ),
    );
  }

  //Crear un renderizador para cada elemento de la lista
  Widget _buildRotatedTravelCard(int itemIndex) {
    return Container(
      //Rellene verticalmente todos los elementos no seleccionados para hacerlos más pequeños. El widget AnimatedPadding maneja la animación..
      child: Rotation3d(
        rotationY: _normalizedOffset * _maxRotation,
        //Cree el renderizador de contenido real para nuestra lista.
        child: TravelCardRenderer(
          //Pase el desplazamiento, el renderizador puede actualizar su propia vista desde allí
          _normalizedOffset,
          //Pase en el camino de la ciudad para ver los enlaces de recursos de imagen.
          city: widget.cities[itemIndex % widget.cities.length],
          cardWidth: _cardWidth,
          cardHeight: _cardHeight - 50,
        ),
      ),
    );
  }

  //Verifique las notificaciones que aparecen desde ListView, úselas para actualizar nuestro estado currentOffset y isScrolling
  bool _handleScrollNotifications(Notification notification) {
    //Actualización de desplazamiento, agregue a nuestro desplazamiento actual, pero limite a -1 y 1
    if (notification is ScrollUpdateNotification) {
      if (_isScrolling) {
        double dx = notification.metrics.pixels - _prevScrollX;
        double scrollFactor = .01;
        double newOffset = (_normalizedOffset + dx * scrollFactor);
        _setOffset(newOffset.clamp(-1.0, 1.0));
      }
      _prevScrollX = notification.metrics.pixels;
      //Calculate the index closest to middle
      //_focusedIndex = (_prevScrollX / (_itemWidth + _listItemPadding)).round();
      final currentPage = _pageController?.page?.round();
      if (currentPage != null) {
        widget.onCityChange(
            widget.cities.elementAt(currentPage % widget.cities.length));
      }
    }
    //Inicio de desplazamiento
    else if (notification is ScrollStartNotification) {
      _isScrolling = true;
      _prevScrollX = notification.metrics.pixels;
      _tweenController.stop();
    }
    return true;
  }

  //Si el usuario ha liberado un puntero y actualmente se está desplazando, asumiremos que ha terminado de desplazarse y cambiaremos nuestro desplazamiento a cero.
  //Esto es un truco, no podemos estar seguros de que este evento realmente provenga del mismo dedo que se estaba desplazando, pero debería funcionar la mayor parte del tiempo.
  void _handlePointerUp(PointerUpEvent event) {
    if (_isScrolling) {
      _isScrolling = false;
      _startOffsetTweenToZero();
    }
  }

  //Función auxiliar, cada vez que cambiamos el desplazamiento, queremos reconstruir el árbol de widgets, para que todos los renderizadores obtengan el nuevo valor.
  void _setOffset(double value) {
    setState(() {
      _normalizedOffset = value;
    });
  }

  //Interpola nuestro desplazamiento del valor actual a 0
  void _startOffsetTweenToZero() {
    //Reinicie tweenController e inyecte un nuevo valor inicial en la interpolación
    _tween.begin = _normalizedOffset;
    _tweenController.reset();
    _tween.end = 0;
    _tweenController.forward();
  }
}
