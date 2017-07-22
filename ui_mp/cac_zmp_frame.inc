#ifdef PC
	// Button indicies
	#define PRIMARY_WEAPON_BUTTON_INDEX			1
	#define SECONDARY_WEAPON_BUTTON_INDEX		2
	#define PRIMARY_GRENADE_BUTTON_INDEX		3
	#define SPECIAL_GRENADE_BUTTON_INDEX		4
	#define EQUIPMENT_BUTTON_INDEX				5
	#define PERK_1_BUTTON_INDEX					6
	#define PERK_2_BUTTON_INDEX					7
	#define PERK_3_BUTTON_INDEX					8
	#define FACEPAINT_BUTTON_INDEX				9
	
	#define ITEM_HIGHLIGHTED( button_index ) \
		MenuHasFocus() && localVarInt( ui_highlight ) == button_index && localVarBool( ui_hide_cac_item_info_highlights ) == 0

	#define ITEM_NOT_HIGHLIGHTED( button_index ) \
		( MenuHasFocus() && localVarInt( ui_highlight ) != button_index ) || localVarBool( ui_hide_cac_item_info_highlights ) == 1
#else //#ifdef PC
	#define ITEM_HIGHLIGHTED( button_index ) \
		MenuHasFocus() && localVarInt( ui_highlight ) == button_index

	#define ITEM_NOT_HIGHLIGHTED( button_index ) \
		MenuHasFocus() && localVarInt( ui_highlight ) != button_index
#endif //#ifdef PC

// Frame setup
#define	CAC_HEIGHT							NEW_FRAME_DEFAULT_HEIGHT
#define CAC_WIDTH							( CAC_HEIGHT * FRAME_ASPECT_RATIO )

#define COMMON_INFO_BG_COLOR					NEW_FRAME_TRANSPARENCY

#define COMMON_HIGHLIGHT_BG_COLOR				1 1 1 1

#define COMMON_ITEM_INFO_TEXT_SIZE				TEXTSIZE_SMALL

#ifndef COMMON_ITEM_INFO_WIDTH
	#ifdef SPLITSCREEN_ENABLED
		#define COMMON_ITEM_INFO_WIDTH			((NEW_FRAME_BUTTON_WIDTH+20)*SPLITSCREEN_MULTIPLIER)
	#else
		#define COMMON_ITEM_INFO_WIDTH			(NEW_FRAME_BUTTON_WIDTH+20)
	#endif
#endif

#ifndef COMMON_ITEM_INFO_X
	#define COMMON_ITEM_INFO_X					(CAC_WIDTH/2-25-NEW_FRAME_BUTTON_WIDTH)
#endif

#ifndef COMMON_ITEM_INFO_Y
	#define COMMON_ITEM_INFO_Y					(-CAC_HEIGHT/2+NEW_FRAME_BG_Y_OFFSET( CAC_HEIGHT )+20)
#endif
	#ifndef COMMON_ITEM_HORIZONTAL_ALIGN
	#define COMMON_ITEM_HORIZONTAL_ALIGN		HORIZONTAL_ALIGN_CENTER
#endif

#ifdef SPLITSCREEN_ENABLED
	#define UNDERLINE_IMAGE_WIDTH				(COMMON_ITEM_INFO_WIDTH-38*SPLITSCREEN_MULTIPLIER)
	#define UNDERLINE_IMAGE_HEIGHT				(16*SPLITSCREEN_MULTIPLIER)
	#define UNDERLINE_IMAGE_X					(COMMON_ITEM_INFO_X+19*SPLITSCREEN_MULTIPLIER)
#else
	#define UNDERLINE_IMAGE_WIDTH				(COMMON_ITEM_INFO_WIDTH-38)
	#define UNDERLINE_IMAGE_HEIGHT				16
	#define UNDERLINE_IMAGE_X					(COMMON_ITEM_INFO_X+19)
#endif

#undef CAC_COMMON_ANIMATION_STATES
#define CAC_COMMON_ANIMATION_STATES( rgbArg ) \
		NEW_FRAME_TRANSPARENT_STATE( rgbArg )
