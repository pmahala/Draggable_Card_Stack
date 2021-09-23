import 'package:flutter/material.dart';
import 'draggableCard.dart';

class PlayArea extends StatefulWidget {
  @override
  _PlayAreaState createState() => _PlayAreaState();
}

class _PlayAreaState extends State<PlayArea> {
  List<List<DraggableCard>> decks = [];
  List<DraggableCard> tempCardDeck = [];
  List<Widget> rowItem = [];
  int numOfDecks = 2;
  int deckLength = 3;
  double displacement = 50.0;
  late Row currentRow;
  int cardIndex = 1;
  List<GlobalKey> _keys = [];
  List<double> xCoordinatesOfStacks = [];

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance!.addPostFrameCallback(_afterLayout);
    super.initState();
    currentRow = initDeck();
    print(xCoordinatesOfStacks);
  }

  _afterLayout(_) {
    for (int i = 0; i < numOfDecks; i++) {
      final RenderBox? renderBoxRed =
          _keys[i].currentContext!.findRenderObject() as RenderBox?;
      final sizeRed = renderBoxRed!.size;
      print("SIZE of Red: $sizeRed");
      final positionRed = renderBoxRed.localToGlobal(Offset.zero);
      print("POSITION of Red: $positionRed ");
      xCoordinatesOfStacks.add(positionRed.dx);
    }
    print(xCoordinatesOfStacks);
  }

  Row initDeck() {
    for (int i = 0; i < numOfDecks; i++) {
      _keys.add(GlobalKey());
    }

    for (int i = 0; i < numOfDecks; i++) {
      for (int j = 0; j < deckLength; j++) {
        print(cardIndex);
        DraggableCard tempCard = DraggableCard(
          transformIndex: j,
          numID: cardIndex++,
          onPositionChange: (xPos, stackNo, cardIndex) {
            if (stackNo == 0) {
              if (xPos >= xCoordinatesOfStacks[stackNo] &&
                  xPos < xCoordinatesOfStacks[stackNo + 1]) {
                return;
              } else if (xPos >= xCoordinatesOfStacks[stackNo + 1]) {
                DraggableCard card =
                    decks.elementAt(stackNo).elementAt(cardIndex);
                decks.elementAt(stackNo).removeAt(cardIndex);
                card.transformIndex = decks.elementAt(stackNo + 1).length;
                decks.elementAt(stackNo + 1).add(card);
                card.stackNumber = stackNo + 1;
                card.stackCardIndex = decks.elementAt(stackNo + 1).length - 1;
                rowItem = [];
                for (int i = 0; i < numOfDecks; i++) {
                  Widget deckItem = Flexible(
                    key: _keys[i],
                    child: Center(
                      child: Stack(
                        children: decks[i],
                      ),
                    ),
                  );
                  rowItem.add(deckItem);
                }
                setState(() {
                  currentRow = Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: rowItem,
                  );
                });
              }
            }
          },
          stackNumber: i,
          stackCardIndex: j,
        );
        tempCardDeck.add(tempCard);
      }

      decks.add(tempCardDeck);

      tempCardDeck = [];
    }

    for (int i = 0; i < numOfDecks; i++) {
      Widget deckItem = Flexible(
        key: _keys[i],
        child: Center(
          child: Stack(
            children: decks[i],
          ),
        ),
      );
      rowItem.add(deckItem);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draggable Card Stack'),
      ),
      body: Container(
        child: currentRow,
      ),
    );
  }
}
