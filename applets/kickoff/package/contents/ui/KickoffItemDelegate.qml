/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>
    Copyright (C) 2012  Gregor Taetzner <gregor@freenet.de>
    Copyright 2014 Sebastian Kügler <sebas@kde.org>
    Copyright (C) 2015-2018  Eike Hein <hein@kde.org>
    Copyright (C) 2021 by Mikel Johnson <mikel5764@gmail.com>
    Copyright (C) 2021 by Noah Davis <noahadvs@gmail.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Templates 2.15 as T
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami 2.16 as Kirigami
import "code/tools.js" as Tools

T.ItemDelegate {
    id: root

    // model properties
    required property var model
    required property int index
    required property var decoration
    required property string description

    readonly property Flickable view: ListView.view ?? GridView.view
    property alias mouseArea: mouseArea
    readonly property bool textUnderIcon: display === PC3.AbstractButton.TextUnderIcon
    property bool extendHoverMargins: false
    property bool isCategory: false
    readonly property bool hasActionList: model && (model.favoriteId !== null || ("hasActionList" in model && model.hasActionList === true))
    property var actionList: null
    property bool isSearchResult: false
    readonly property bool menuClosed: ActionMenu.menu.status == 3 // corresponds to DialogStatus.Closed

    function openActionMenu(x = undefined, y = undefined) {
        if (!root.hasActionList) { return }
        // fill actionList only when needed to prevent slowness when changing app categories rapidly.
        if (root.actionList === null) {
            let allActions = model.actionList
            const favoriteActions = Tools.createFavoriteActions(
                i18n, //i18n() function callback
                view.model.favoritesModel,
                model.favoriteId)
            if (favoriteActions) {
                if (allActions && allActions.length > 0) {
                    allActions.push({ "type": "separator" });
                    allActions.push.apply(allActions, favoriteActions);
                } else {
                    allActions = favoriteActions;
                }
            }
            root.actionList = allActions
        }
        ActionMenu.menu.visualParent = root
        if (x !== undefined && y !== undefined) {
            ActionMenu.menu.open(x, y)
        } else {
            ActionMenu.menu.openRelative()
        }
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: KickoffSingleton.listItemMetrics.margins.left
        + (!textUnderIcon && mirrored ? KickoffSingleton.fontMetrics.descent : 0)
    rightPadding: KickoffSingleton.listItemMetrics.margins.right
        + (!textUnderIcon && !mirrored ? KickoffSingleton.fontMetrics.descent : 0)
    topPadding: textUnderIcon ? KickoffSingleton.listItemMetrics.margins.top + KickoffSingleton.fontMetrics.descent : KickoffSingleton.listItemMetrics.margins.top
    bottomPadding: KickoffSingleton.listItemMetrics.margins.bottom

    spacing: KickoffSingleton.fontMetrics.descent

    enabled: !model.disabled
    hoverEnabled: false

    icon.width: PlasmaCore.Units.iconSizes.smallMedium
    icon.height: PlasmaCore.Units.iconSizes.smallMedium

    text: model.name ?? model.display
    Accessible.description: root.description != root.text ? root.description : ""

    // Using an action so that it can be replaced or manually triggered
    // using `model` () instead of `root.model` leads to errors about
    // `model` not having the trigger() function
    action: T.Action {
        onTriggered: {
            // Unless we're showing search results, eat the activation if we
            // don't have focus, to prevent the return/enter key from
            // inappropriately activating unfocused items
            if (!root.activeFocus && !root.isSearchResult) {
                return;
            }
            view.currentIndex = index
            // if successfully triggered, close popup
            if(view.model.trigger(index, "", null)) {
                plasmoid.expanded = false
            }
        }
    }

    background: null
    contentItem: GridLayout {
        baselineOffset: label.y + label.baselineOffset
        columnSpacing: parent.spacing
        rowSpacing: parent.spacing
        flow: root.textUnderIcon ? GridLayout.TopToBottom : GridLayout.LeftToRight
        PlasmaCore.IconItem {
            id: iconItem
            Layout.alignment: root.textUnderIcon ? Qt.AlignHCenter | Qt.AlignBottom : Qt.AlignLeft | Qt.AlignVCenter
            implicitWidth: root.icon.width
            implicitHeight: root.icon.height
            animated: false
            usesPlasmaTheme: false
            source: root.decoration || root.icon.name || root.icon.source
        }
        PC3.Label {
            id: label
            Layout.alignment: root.textUnderIcon ? Qt.AlignHCenter | Qt.AlignTop : Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.preferredHeight: root.textUnderIcon && lineCount === 1 ? implicitHeight * 2 : implicitHeight
            Layout.rightMargin: root.indicator && root.indicator.visible ? root.spacing + root.indicator.width : 0
            text: root.text
            elide: Text.ElideRight
            horizontalAlignment: root.textUnderIcon ? Text.AlignHCenter : Text.AlignLeft
            verticalAlignment: root.textUnderIcon ? Text.AlignTop : Text.AlignVCenter
            maximumLineCount: 2
            wrapMode: Text.Wrap
        }
    }

    PC3.Label {
        id: descriptionLabel
        parent: root
        anchors {
            left: root.contentItem.left
            right: root.contentItem.right
            baseline: root.contentItem.baseline
            leftMargin: root.textUnderIcon ? 0 : root.implicitContentWidth + root.spacing
            rightMargin: root.indicator && root.indicator.visible ? root.spacing + root.indicator.width : 0
            baselineOffset: root.textUnderIcon ? implicitHeight : 0
        }
        visible: !textUnderIcon && text.length > 0 && text !== root.text && label.lineCount === 1
        enabled: false
        text: root.description
        elide: Text.ElideRight
        horizontalAlignment: root.textUnderIcon ? Text.AlignHCenter : Text.AlignRight
        verticalAlignment: root.textUnderIcon ? Text.AlignTop : Text.AlignVCenter
        maximumLineCount: 1
    }

    MouseArea {
        id: mouseArea
        parent: root
        anchors.fill: parent
        anchors.margins: 1
        anchors.leftMargin: root.extendHoverMargins ? (!mirrored ? -root.view.leftMargin : -root.view.rightMargin) : anchors.margins
        anchors.rightMargin: root.extendHoverMargins ? (mirrored ? -root.view.rightMargin : -root.view.leftMargin) : anchors.margins
        hoverEnabled: root.view && !root.view.movedWithKeyboard
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        // Using onPositionChanged instead of onEntered to prevent changing
        // categories while scrolling with the mouse wheel.
        onPositionChanged: {
            // forceActiveFocus() touches multiple items, so check for
            // activeFocus first to be more efficient.
            if (!activeFocus) {
                root.forceActiveFocus(Qt.MouseFocusReason)
            }
            // No need to check currentIndex first because it's
            // built into QQuickListView::setCurrentIndex() already
            root.view.currentIndex = index
        }
        onClicked: {
            if (mouse.button === Qt.LeftButton) {
                root.forceActiveFocus(Qt.MouseFocusReason)
                root.action.trigger() // clicked() is emmitted when action is triggered
            } else if (mouse.button === Qt.RightButton) {
                root.forceActiveFocus(Qt.MouseFocusReason)
                root.clicked() // does not trigger the action
                root.openActionMenu(mouseX, mouseY)
            }
        }
        
        onPressAndHold: { // act like right click on press and hold (with touch)
            root.forceActiveFocus(Qt.MouseFocusReason)
            root.clicked() // does not trigger the action
            root.openActionMenu(mouseX, mouseY)
        }
    }

    PC3.ToolTip.text: {
        if (label.truncated && descriptionLabel.truncated) {
            return `${text} (${description})`
        } else if (descriptionLabel.truncated) {
            return description
        } else {
            return text
        }
    }
    PC3.ToolTip.visible: mouseArea.containsMouse && ((label.visible && label.truncated) || (descriptionLabel.visible && descriptionLabel.truncated))
    PC3.ToolTip.delay: Kirigami.Units.toolTipDelay

    Component {
        id: arrowIndicator
        PlasmaCore.SvgItem {
            anchors.right: parent.contentItem.right
            anchors.verticalCenter: parent.contentItem.verticalCenter
            implicitWidth: naturalSize.width
            implicitHeight: naturalSize.height
            svg: KickoffSingleton.arrowsSvg
            elementId: parent.mirrored ? "left-arrow" : "right-arrow"
        }
    }

    onIsCategoryChanged: {
        if (isCategory) {
            indicator = arrowIndicator.createObject(root)
        } else {
            indicator = null
        }
    }
}