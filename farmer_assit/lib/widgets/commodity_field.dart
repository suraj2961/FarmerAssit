import 'package:flutter/material.dart';
import '../config/negilu_tokens.dart';

const List<String> karnatakaCrops = [
  'Tomato',
  'Onion',
  'Potato',
  'Rice',
  'Ragi',
  'Maize',
  'Areca nut',
  'Coconut',
  'Cotton',
  'Sugarcane',
  'Groundnut',
  'Soyabean',
  'Chilli',
  'Ginger',
  'Turmeric',
  'Banana',
  'Mango',
  'Grapes',
  'Coffee',
  'Pepper',
  'Cashewnut',
  'Tur',
  'Bengal Gram',
  'Green Gram',
  'Jowar',
  'Bajra',
  'Wheat',
  'Cabbage',
  'Cauliflower',
  'Brinjal',
  'Beans',
  'Carrot',
  'Beetroot',
  'Cucumber',
  'Papaya',
];

class CommodityField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const CommodityField({
    super.key,
    required this.controller,
    this.labelText = 'Commodity',
    this.onSubmitted,
    this.onChanged,
  });

  @override
  State<CommodityField> createState() => _CommodityFieldState();
}

class _CommodityFieldState extends State<CommodityField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return karnatakaCrops;
        }
        return karnatakaCrops.where(
          (crop) => crop.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            shadowColor: Colors.black26,
            borderRadius: NegiluRadii.borderFull,
            color: NegiluColors.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: NegiluSpacing.s6),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    borderRadius: NegiluRadii.borderLg,
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: NegiluSpacing.s16,
                        vertical: NegiluSpacing.s10,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.eco_outlined, size: 16, color: NegiluColors.brandGreen),
                          const SizedBox(width: NegiluSpacing.s10),
                          Text(
                            option,
                            style: NegiluTypography.body(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: NegiluColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          style: NegiluTypography.body(fontSize: 14, color: NegiluColors.textPrimary),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: 'Start typing, e.g. Tomato (ಟೊಮೆಟೊ)',
            isDense: true,
            filled: true,
            fillColor: NegiluColors.surface,
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: NegiluColors.brandGreenDark,
            ),
            suffixIcon: textController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: NegiluColors.textMuted),
                    onPressed: () {
                      textController.clear();
                      setState(() {});
                      widget.onChanged?.call('');
                      widget.onSubmitted?.call('');
                    },
                  )
                : const Icon(Icons.arrow_drop_down, color: NegiluColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: NegiluRadii.borderFull,
              borderSide: const BorderSide(color: Color(0xFFDCCFBD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: NegiluRadii.borderFull,
              borderSide: const BorderSide(color: Color(0xFFDCCFBD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: NegiluRadii.borderFull,
              borderSide: const BorderSide(
                color: NegiluColors.brandGreenDark,
                width: 1.8,
              ),
            ),
          ),
          onChanged: (val) {
            setState(() {});
            widget.onChanged?.call(val);
          },
          onSubmitted: (value) {
            onFieldSubmitted();
            widget.onSubmitted?.call(value);
          },
        );
      },
      onSelected: (value) {
        widget.onChanged?.call(value);
        widget.onSubmitted?.call(value);
      },
    );
  }
}
