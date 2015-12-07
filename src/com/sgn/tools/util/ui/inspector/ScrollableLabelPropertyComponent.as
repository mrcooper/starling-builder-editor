package com.sgn.tools.util.ui.inspector
{

import avmplus.getQualifiedClassName;

import com.sgn.starlingbuilder.editor.data.EmbeddedData;
import com.sgn.tools.util.feathers.FeathersUIUtil;

import feathers.controls.Label;

import flash.geom.Point;

import flash.net.getClassByAlias;

import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.utils.describeType;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class ScrollableLabelPropertyComponent extends BasePropertyComponent
{
    private static const HELPER_POINT:Point = new Point();

    private var _label:Label;
    private var _isFractional:Boolean;

    public function ScrollableLabelPropertyComponent(propertyRetriever:IPropertyRetriever, param:Object)
    {
        super(propertyRetriever, param);

        _label = FeathersUIUtil.labelWithText(_param.name);
        _label.width = 70;
        _label.wordWrap = true;

        var obj:Object = describeType(_propertyRetriever.target)..accessor.(@name==_param.name)[0];
        var propertyType:String = obj ? obj.@type : "";
        _isFractional = propertyType == "Number";
        var isNumerical:Boolean = _isFractional || propertyType == "int" || propertyType == "uint";

        if (isNumerical)
            _label.addEventListener(TouchEvent.TOUCH, onTouch);

        addChild(_label);
    }

    private function onTouch(event:TouchEvent):void
    {
        var touch:Touch = event.getTouch(_label);
        if (touch)
        {
            switch (touch.phase)
            {
                case TouchPhase.HOVER:
                    Mouse.cursor = EmbeddedData.HORIZONTAL_ARROWS;
                    break;

                case TouchPhase.MOVED:
                    _oldValue = _propertyRetriever.get(_param.name);
                    touch.getMovement(_label, HELPER_POINT);
                    var delta:Number = HELPER_POINT.x;
                    if (_isFractional)
                    {
                        delta = Math.abs(HELPER_POINT.x) <= 10
                            ? HELPER_POINT.x / 100
                            : Math.abs(HELPER_POINT.x) <= 20
                                ? HELPER_POINT.x / 10
                                : HELPER_POINT.x;
                    }
                    _propertyRetriever.set(_param.name, _oldValue + delta);
                    setChanged();
                    break;

                case TouchPhase.ENDED:
                    Mouse.cursor = MouseCursor.AUTO;
                    break;
            }
        }
        else
        {
            Mouse.cursor = MouseCursor.AUTO;
        }
    }

    override public function dispose():void
    {
        _label.removeEventListener(TouchEvent.TOUCH, onTouch);

        super.dispose();
    }
}
}
