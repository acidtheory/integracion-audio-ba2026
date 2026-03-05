/////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Audiokinetic Wwise generated include file. Do not edit.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef __WWISE_IDS_H__
#define __WWISE_IDS_H__

#include <AK/SoundEngine/Common/AkTypes.h>

namespace AK
{
    namespace EVENTS
    {
        static const AkUniqueID PLAY_MX_SW = 3349137146U;
        static const AkUniqueID PLAY_SFX_HIT = 1376640657U;
        static const AkUniqueID PLAY_SFX_NAVE = 2820221086U;
        static const AkUniqueID PLAY_SFX_RADAR = 3501558446U;
        static const AkUniqueID PLAY_SFX_RADAR_FIN = 2874623752U;
        static const AkUniqueID PLAY_WHA = 2972765248U;
        static const AkUniqueID STOP_MX_SW = 1505221168U;
    } // namespace EVENTS

    namespace STATES
    {
        namespace MX_MUSICA
        {
            static const AkUniqueID GROUP = 2367315283U;

            namespace STATE
            {
                static const AkUniqueID GAMEPLAY = 89505537U;
                static const AkUniqueID LOSE = 221232726U;
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID WIN = 979765101U;
            } // namespace STATE
        } // namespace MX_MUSICA

        namespace MX_VIDAS
        {
            static const AkUniqueID GROUP = 3497261126U;

            namespace STATE
            {
                static const AkUniqueID NONE = 748895195U;
            } // namespace STATE
        } // namespace MX_VIDAS

        namespace PAUSA
        {
            static const AkUniqueID GROUP = 3092587489U;

            namespace STATE
            {
                static const AkUniqueID NONE = 748895195U;
                static const AkUniqueID PAUSA_OFF = 2659475283U;
                static const AkUniqueID PAUSA_ON = 549173535U;
            } // namespace STATE
        } // namespace PAUSA

    } // namespace STATES

    namespace GAME_PARAMETERS
    {
        static const AkUniqueID MX_VIDAS = 3497261126U;
        static const AkUniqueID SFX_NAVE = 742989333U;
        static const AkUniqueID SFX_RADAR_VOL = 1388700061U;
        static const AkUniqueID SS_AIR_FEAR = 1351367891U;
        static const AkUniqueID SS_AIR_FREEFALL = 3002758120U;
        static const AkUniqueID SS_AIR_FURY = 1029930033U;
        static const AkUniqueID SS_AIR_MONTH = 2648548617U;
        static const AkUniqueID SS_AIR_PRESENCE = 3847924954U;
        static const AkUniqueID SS_AIR_RPM = 822163944U;
        static const AkUniqueID SS_AIR_SIZE = 3074696722U;
        static const AkUniqueID SS_AIR_STORM = 3715662592U;
        static const AkUniqueID SS_AIR_TIMEOFDAY = 3203397129U;
        static const AkUniqueID SS_AIR_TURBULENCE = 4160247818U;
    } // namespace GAME_PARAMETERS

    namespace BANKS
    {
        static const AkUniqueID INIT = 1355168291U;
        static const AkUniqueID MAIN = 3161908922U;
    } // namespace BANKS

    namespace BUSSES
    {
        static const AkUniqueID MAIN_AUDIO_BUS = 2246998526U;
    } // namespace BUSSES

    namespace AUDIO_DEVICES
    {
        static const AkUniqueID NO_OUTPUT = 2317455096U;
        static const AkUniqueID SYSTEM = 3859886410U;
    } // namespace AUDIO_DEVICES

}// namespace AK

#endif // __WWISE_IDS_H__
