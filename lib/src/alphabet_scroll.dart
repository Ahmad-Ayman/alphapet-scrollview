import 'dart:async';

import 'package:alphabet_scroll_view/src/meta.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

enum LetterAlignment { left, right }

class AlphabetScrollView extends StatefulWidget {
  AlphabetScrollView(
      {Key? key,
      required this.list,
      required this.nodeIncrementValue,
      this.selectedColor = Colors.transparent,
      this.alignment = LetterAlignment.right,
      this.isAlphabetsFiltered = true,
      this.overlayWidget,
      required this.visibleSelectedTextStyle,
      required this.unselectedTextStyle,
      this.itemExtent = 40,
      this.dotsNumber = 4,
        this.maxNumber= 0,
      required this.itemBuilder})
      : super(key: key);

  /// List of Items should be non Empty
  /// and you must map your
  /// ```
  ///  List<T> to List<AlphaModel>
  ///  e.g
  ///  List<UserModel> _list;
  ///  _list.map((user)=>AlphaModel(user.name)).toList();
  /// ```
  /// where each item of this ```list``` will be mapped to
  /// each widget returned by ItemBuilder to uniquely identify
  /// that widget.
  final List<AlphaModel> list;
  final int maxNumber;
  /// List of Indexes to be hidden in indicator,
  /// items indexes that are exists in this list will be shown as "."
  /// Otherwise it will be shown normally.
  // List<int> hiddenIndicatorIndexes;

  // do not change this value
  final int dotsNumber;

  final int nodeIncrementValue;

  Color selectedColor;

  /// ```itemExtent``` specifies the max height of the widget returned by
  /// itemBuilder if not specified defaults to 40.0
  final double itemExtent;

  /// Alignment for the Alphabet List
  /// can be aligned on either left/right side
  /// of the screen
  final LetterAlignment alignment;

  /// defaults to ```true```
  /// if specified as ```false```
  /// all alphabets will be shown regardless of
  /// whether the item in the [list] exists starting with
  /// that alphabet.

  final bool isAlphabetsFiltered;

  /// Widget to show beside the selected alphabet
  /// if not specified it will be hidden.
  /// ```
  /// overlayWidget:(value)=>
  ///    Container(
  ///       height: 50,
  ///       width: 50,
  ///       alignment: Alignment.center,
  ///       color: Theme.of(context).primaryColor,
  ///       child: Text(
  ///                 '$value'.toUpperCase(),
  ///                  style: TextStyle(fontSize: 20, color: Colors.white),
  ///              ),
  ///      )
  /// ```

  final Widget Function(String)? overlayWidget;

  /// Text styling for the selected alphabet by which
  /// we can customize the font color, weight, size etc.
  /// ```
  /// selectedTextStyle:
  ///   TextStyle(
  ///     fontWeight: FontWeight.bold,
  ///     color: Colors.black,
  ///     fontSize: 20
  ///   )
  /// ```

  final TextStyle visibleSelectedTextStyle;

  /// Text styling for the unselected alphabet by which
  /// we can customize the font color, weight, size etc.
  /// ```
  /// unselectedTextStyle:
  ///   TextStyle(
  ///     fontWeight: FontWeight.normal,
  ///     color: Colors.grey,
  ///     fontSize: 18
  ///   )
  /// ```

  final TextStyle unselectedTextStyle;

  /// The itemBuilder must return a non-null widget and the third paramter id specifies
  /// the string mapped to this widget from the ```[list]``` passed.

  Widget Function(BuildContext, int index, String key, String value)
      itemBuilder;

  @override
  _AlphabetScrollViewState createState() => _AlphabetScrollViewState();
}

class _AlphabetScrollViewState extends State<AlphabetScrollView> {
  void init() {
    // generate numbers from 1 to 1000 to be used as alphabets
    alphabets = List.generate(1000, (index) => (index + 1).toString());

    // widget.list
    //     .sort((x, y) => x.key.toLowerCase().compareTo(y.key.toLowerCase()));

    _list = widget.list;
    setState(() {});

    /// filter Out AlphabetList
    if (widget.isAlphabetsFiltered) {
      List<String> temp = [];

      alphabets.forEach((letter) {
        AlphaModel? firstAlphabetElement = _list.firstWhereOrNull((item) {
          return int.tryParse(item.key) == int.tryParse(letter);
        });
        if (firstAlphabetElement != null) {
          temp.add(letter);
        }
      });

      _filteredAlphabets = temp;
    } else {
      _filteredAlphabets = alphabets;
    }
    calculateFirstIndex();
    setState(() {});
  }

  @override
  void initState() {
    timer = RestartableTimer(Duration(milliseconds: 1000), () {});

    if(widget.maxNumber == 30 || widget.maxNumber == 114) {
      _visibleNumberJumpValue =5; // 20
       // _visibleNumberJumpValue =
       //    widget.list.length ~/ (widget.dotsNumber ); // 20
    // }else if (widget.maxNumber == 114){
    //   _visibleNumberJumpValue = 5; // 20
     }
    else{
      _visibleNumberJumpValue =
          widget.list.length ~/ (widget.dotsNumber + 1); // 20
    }

    print('visible number : ${_visibleNumberJumpValue}');
    // widget.dotsJumpValue = _visibleNumberJumpValue ~/ (widget.dotsNumber - 1); // 5
    // dotsJumpValue = 7; // 5
    init();
    if (listController.hasClients) {
      maxScroll = listController.position.maxScrollExtent;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      listController.addListener(() {
        if (timer.isActive == false) {
          int topIndex = (listController.offset) ~/ widget.itemExtent;

          int sliderIndex = _filteredAlphabets
              .indexOf(this._list[topIndex].key.toLowerCase());

          if (sliderIndex % widget.nodeIncrementValue == 0 ||
              sliderIndex % _visibleNumberJumpValue == 0)
            _selectedIndexNotifier.value = sliderIndex;
        }
      });
    });
    super.initState();
  }

  ScrollController listController = ScrollController();
  final _selectedIndexNotifier = ValueNotifier<int>(0);
  final positionNotifer = ValueNotifier<Offset>(Offset(0, 0));
  final Map<String, int> firstIndexPosition = {};
  List<String> _filteredAlphabets = [];
  final letterKey = GlobalKey();
  int _visibleNumberJumpValue = 1;
  int lastSelectedIndex = 0;
  List<AlphaModel> _list = [];
  List<String> alphabets = [];
  bool isLoading = false;
  bool isScrolling = false;
  bool isFocused = false;
  Offset verticalOffset = Offset(0, 0);
  late RestartableTimer timer;
  final key = GlobalKey();
  // double lastVerticalPosition = 0.0;
  // double overlayVerticalPosition = 0;

  @override
  void didUpdateWidget(covariant AlphabetScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.list != widget.list ||
        oldWidget.isAlphabetsFiltered != widget.isAlphabetsFiltered) {
      _list.clear();
      firstIndexPosition.clear();
      init();
    }
  }

  int getCurrentIndex(double vPosition) {
    print('vPosition : ${vPosition}');
    try {
      final double kAlphabetHeight =
          letterKey.currentContext!.size!.height / widget.nodeIncrementValue;
      final int selectedIndex = (vPosition ~/ kAlphabetHeight);

      // print(
      //     "subtraction: ${vPosition - lastVerticalPosition}, touchPosition: $vPosition");
      // double diff = vPosition - lastVerticalPosition;
      // if (diff < 50 && diff > 0) return lastSelectedIndex;

      print('selected index : ${selectedIndex}');
      if (selectedIndex % widget.nodeIncrementValue == 0 ||
          selectedIndex % _visibleNumberJumpValue == 0) {
        // lastVerticalPosition = vPosition;
        lastSelectedIndex = selectedIndex;
        print('last selected index : ${lastSelectedIndex}');
      }
      return lastSelectedIndex;
    } catch (e) {
      return lastSelectedIndex;
    }
  }

  /// calculates and Maintains a map of
  /// [letter:index] of the position of the first Item in list
  /// starting with that letter.
  /// This helps to avoid recomputing the position to scroll to
  /// on each Scroll.
  void calculateFirstIndex() {
    _filteredAlphabets.forEach((letter) {
      AlphaModel? firstElement = _list.firstWhereOrNull(
          (item) => item.key.toLowerCase().startsWith(letter));
      if (firstElement != null) {
        int index = _list.indexOf(firstElement);
        firstIndexPosition[letter] = index;
      }
    });
  }

  void scrolltoIndex(int x, Offset offset) {
    int index = firstIndexPosition[_filteredAlphabets[x].toLowerCase()]!;
    final scrollToPostion = widget.itemExtent * (index -1) ;
    if (index != null) {
      isScrolling = true;
      timer.reset();
      listController
          .animateTo((scrollToPostion),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut)
          .then((value) async {
        // isScrolling = true;
        // await Future.delayed(Duration(milliseconds: 1000));
        //
        // isScrolling = false;
      });

      // isScrolling = false;
    }
    positionNotifer.value = offset;
  }

  void onVerticalDrag(Offset offset) {
    int index = getCurrentIndex(offset.dy);
    if (index < 0 || index >= _filteredAlphabets.length) return;

    _selectedIndexNotifier.value = index;
    setState(() {
      isFocused = true;
    });
    scrolltoIndex(index, offset);
  }

  double? maxScroll;

  Widget? getIndicatorText(int index, String value, bool selected) {
    // text conditions
    String text = "";
    Widget textWidget = SizedBox();
    // if (index == 60) {
    //   print("");
    // }

    // _visible = 4
    // node = 4

    print('indexes : ${index} -- value : ${value}  -- selected : ${selected} -- visible : ${_visibleNumberJumpValue}');
    if(_visibleNumberJumpValue == 5) {
      if (index == 0 ) {
        text = value.toUpperCase();
        print('index in $index : text = ${text}');
      }
      else    if(index == 113){
        text = value.toUpperCase();
      }
      else if (
      // index % widget.nodeIncrementValue == 0 &&
      index % _visibleNumberJumpValue != (_visibleNumberJumpValue - 1)) {
        text = ".";
        print('index in $index : text = ${text}');
      }
      else
      if (index % _visibleNumberJumpValue == (_visibleNumberJumpValue - 1)) {
        text = value.toUpperCase();
        print('index in $index : text = ${text}');
      }
    }
    // else if (_visibleNumberJumpValue == 20){
    //   if (index == 0) {
    //     text = value.toUpperCase();
    //     print('index  in $index : text = ${text}');
    //   }
    //   else if(index == 113){
    //     text = value.toUpperCase();
    //   }
    //   else if (
    //   // index % widget.nodeIncrementValue == 0 &&
    //   index % _visibleNumberJumpValue != (_visibleNumberJumpValue - 1)  && int.parse(value) % 5 == 0 ) {
    //     text = ".";
    //     print('index in $index : text = ${text}');
    //   }
    //   else
    //   if (index % _visibleNumberJumpValue == (_visibleNumberJumpValue - 1)) {
    //     text = value.toUpperCase();
    //     print('index in $index : text = ${text}');
    //   }
    // }
    // widget conditions
    // if (index % widget.nodeIncrementValue == 0 ||
    //     index % _visibleNumberJumpValue == 0)
    if(text.isNotEmpty) {
      textWidget = Text(
        text,
        style: selected
            ? widget.visibleSelectedTextStyle
            : widget.unselectedTextStyle,
        textAlign: TextAlign.center,
      );
    }
    else{
      return null;
    }

    return textWidget;

    // return Text(
    //   index % dotsJumpValue == 0 ? "." ? index % visibleNumberJumpValue == 0 ?  _filteredAlphabets[index].toUpperCase() : ,
    //
    //   // widget.hiddenIndicatorIndexes.contains(index)
    //   //     ? "."
    //   //     : _filteredAlphabets[index].toUpperCase(),
    //   style: selected == index
    //       ? widget.visibleSelectedTextStyle
    //       : widget.unselectedTextStyle,
    //   textAlign: TextAlign.center,
    //   // style: TextStyle(
    //   //     fontSize: 12,
    //   //     fontWeight: selected == x
    //   //         ? FontWeight.bold
    //   //         : FontWeight.normal),
    // )
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: Stack(
        children: [
           ListView.builder(
                controller: listController,
                scrollDirection: Axis.vertical,
                itemCount: _list.length,
                physics: ClampingScrollPhysics(),
                itemBuilder: (_, int index) {
                  return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: widget.itemExtent),
                      child: widget.itemBuilder(
                          _, index, _list[index].key, _list[index].value));
                }),

          Align(
            alignment: widget.alignment == LetterAlignment.left
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              key: key,
              height: MediaQuery.sizeOf(context).height,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onVerticalDragStart: (z) {
                  verticalOffset = z.localPosition;
                  onVerticalDrag(z.localPosition);
                },
                onVerticalDragUpdate: (z) => onVerticalDrag(z.localPosition),
                onVerticalDragEnd: (z) {
                  setState(() {
                    isFocused = false;
                  });
                },
                child: ValueListenableBuilder<int>(
                    valueListenable: _selectedIndexNotifier,
                    builder: (context, int selectedIndex, Widget? child) {
                      return SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              _filteredAlphabets.length,
                              (index) =>
                                  getIndicatorText(
                                      index,
                                      _filteredAlphabets[index].toUpperCase(),
                                      selectedIndex == index) !=null ?
                                  GestureDetector(
                                key: (index == selectedIndex &&
                                        (index % widget.nodeIncrementValue == 0 ||
                                            index % _visibleNumberJumpValue == 0))
                                    ? letterKey
                                    : null,
                                onTap: () {
                                  _selectedIndexNotifier.value = index;
                                  scrolltoIndex(index, positionNotifer.value);
                                },
                                child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 5,vertical: 4),

                                    decoration: BoxDecoration(
                                      color: selectedIndex == index
                                          ? widget.selectedColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: getIndicatorText(
                                        index,
                                        _filteredAlphabets[index].toUpperCase(),
                                        selectedIndex == index)

                                    // (index == 0 ||
                                    //         index % dotsJumpValue == 0)
                                    //     ? Text(
                                    //         index % dotsJumpValue == 0 ? "." ? index % visibleNumberJumpValue == 0 ?  _filteredAlphabets[index].toUpperCase() : ,
                                    //
                                    //         // widget.hiddenIndicatorIndexes.contains(index)
                                    //         //     ? "."
                                    //         //     : _filteredAlphabets[index].toUpperCase(),
                                    //         style: selected == index
                                    //             ? widget.visibleSelectedTextStyle
                                    //             : widget.unselectedTextStyle,
                                    //         textAlign: TextAlign.center,
                                    //         // style: TextStyle(
                                    //         //     fontSize: 12,
                                    //         //     fontWeight: selected == x
                                    //         //         ? FontWeight.bold
                                    //         //         : FontWeight.normal),
                                    //       )
                                    //     : SizedBox()
                                    ),
                              ):SizedBox.shrink(),
                            )),
                      );
                    }),
              ),
            ),
          ),
          !isFocused
              ? Container()
              : ValueListenableBuilder<Offset>(
                  valueListenable: positionNotifer,
                  builder:
                      (BuildContext context, Offset position, Widget? child) {
                    (position.dy) -
                        (widget.visibleSelectedTextStyle.height! *
                            widget.visibleSelectedTextStyle.fontSize!);
                    return Positioned(
                        right:
                            widget.alignment == LetterAlignment.right ? 40 : null,
                        left:
                            widget.alignment == LetterAlignment.left ? 40 : null,
                        top: (position.dy) -
                            (widget.visibleSelectedTextStyle.height! *
                                widget.visibleSelectedTextStyle.fontSize!),
                        child: widget.overlayWidget == null
                            ? Container()
                            : widget.overlayWidget!(_filteredAlphabets[
                                _selectedIndexNotifier.value]));
                  })
        ],
      ),
    );
  }
}

class AlphaModel {
  final String key;
  final String value;

  AlphaModel(this.key, this.value);
}
