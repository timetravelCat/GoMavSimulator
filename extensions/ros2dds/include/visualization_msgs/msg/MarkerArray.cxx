// Copyright 2016 Proyectos y Sistemas de Mantenimiento SL (eProsima).
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/*!
 * @file MarkerArray.cpp
 * This source file contains the definition of the described types in the IDL file.
 *
 * This file was generated by the tool gen.
 */

#ifdef _WIN32
// Remove linker warning LNK4221 on Visual Studio
namespace {
char dummy;
}  // namespace
#endif  // _WIN32

#include "MarkerArray.h"
#include <fastcdr/Cdr.h>

#include <fastcdr/exceptions/BadParamException.h>
using namespace eprosima::fastcdr::exception;

#include <utility>

#define visualization_msgs_msg_MarkerArray_max_cdr_typesize 724001ULL;
#define geometry_msgs_msg_Quaternion_max_cdr_typesize 32ULL;
#define sensor_msgs_msg_CompressedImage_max_cdr_typesize 632ULL;
#define geometry_msgs_msg_Vector3_max_cdr_typesize 24ULL;
#define builtin_interfaces_msg_Time_max_cdr_typesize 8ULL;
#define visualization_msgs_msg_MeshFile_max_cdr_typesize 364ULL;
#define geometry_msgs_msg_Pose_max_cdr_typesize 56ULL;
#define visualization_msgs_msg_Marker_max_cdr_typesize 7241ULL;
#define builtin_interfaces_msg_Duration_max_cdr_typesize 8ULL;
#define visualization_msgs_msg_UVCoordinate_max_cdr_typesize 8ULL;
#define geometry_msgs_msg_Point_max_cdr_typesize 24ULL;
#define std_msgs_msg_ColorRGBA_max_cdr_typesize 16ULL;
#define std_msgs_msg_Header_max_cdr_typesize 268ULL;
#define visualization_msgs_msg_MarkerArray_max_key_cdr_typesize 0ULL;
#define geometry_msgs_msg_Quaternion_max_key_cdr_typesize 0ULL;
#define sensor_msgs_msg_CompressedImage_max_key_cdr_typesize 0ULL;
#define geometry_msgs_msg_Vector3_max_key_cdr_typesize 0ULL;
#define builtin_interfaces_msg_Time_max_key_cdr_typesize 0ULL;
#define visualization_msgs_msg_MeshFile_max_key_cdr_typesize 0ULL;
#define geometry_msgs_msg_Pose_max_key_cdr_typesize 0ULL;
#define visualization_msgs_msg_Marker_max_key_cdr_typesize 0ULL;
#define builtin_interfaces_msg_Duration_max_key_cdr_typesize 0ULL;
#define visualization_msgs_msg_UVCoordinate_max_key_cdr_typesize 0ULL;
#define geometry_msgs_msg_Point_max_key_cdr_typesize 0ULL;
#define std_msgs_msg_ColorRGBA_max_key_cdr_typesize 0ULL;
#define std_msgs_msg_Header_max_key_cdr_typesize 0ULL;

visualization_msgs::msg::MarkerArray::MarkerArray()
{
    // sequence<visualization_msgs::msg::Marker> m_markers


}

visualization_msgs::msg::MarkerArray::~MarkerArray()
{
}

visualization_msgs::msg::MarkerArray::MarkerArray(
        const MarkerArray& x)
{
    m_markers = x.m_markers;
}

visualization_msgs::msg::MarkerArray::MarkerArray(
        MarkerArray&& x) noexcept 
{
    m_markers = std::move(x.m_markers);
}

visualization_msgs::msg::MarkerArray& visualization_msgs::msg::MarkerArray::operator =(
        const MarkerArray& x)
{

    m_markers = x.m_markers;

    return *this;
}

visualization_msgs::msg::MarkerArray& visualization_msgs::msg::MarkerArray::operator =(
        MarkerArray&& x) noexcept
{

    m_markers = std::move(x.m_markers);

    return *this;
}

bool visualization_msgs::msg::MarkerArray::operator ==(
        const MarkerArray& x) const
{

    return (m_markers == x.m_markers);
}

bool visualization_msgs::msg::MarkerArray::operator !=(
        const MarkerArray& x) const
{
    return !(*this == x);
}

size_t visualization_msgs::msg::MarkerArray::getMaxCdrSerializedSize(
        size_t current_alignment)
{
    static_cast<void>(current_alignment);
    return visualization_msgs_msg_MarkerArray_max_cdr_typesize;
}

size_t visualization_msgs::msg::MarkerArray::getCdrSerializedSize(
        const visualization_msgs::msg::MarkerArray& data,
        size_t current_alignment)
{
    (void)data;
    size_t initial_alignment = current_alignment;


    current_alignment += 4 + eprosima::fastcdr::Cdr::alignment(current_alignment, 4);


    for(size_t a = 0; a < data.markers().size(); ++a)
    {
        current_alignment += visualization_msgs::msg::Marker::getCdrSerializedSize(data.markers().at(a), current_alignment);}

    return current_alignment - initial_alignment;
}

void visualization_msgs::msg::MarkerArray::serialize(
        eprosima::fastcdr::Cdr& scdr) const
{

    scdr << m_markers;
}

void visualization_msgs::msg::MarkerArray::deserialize(
        eprosima::fastcdr::Cdr& dcdr)
{

    dcdr >> m_markers;}

/*!
 * @brief This function copies the value in member markers
 * @param _markers New value to be copied in member markers
 */
void visualization_msgs::msg::MarkerArray::markers(
        const std::vector<visualization_msgs::msg::Marker>& _markers)
{
    m_markers = _markers;
}

/*!
 * @brief This function moves the value in member markers
 * @param _markers New value to be moved in member markers
 */
void visualization_msgs::msg::MarkerArray::markers(
        std::vector<visualization_msgs::msg::Marker>&& _markers)
{
    m_markers = std::move(_markers);
}

/*!
 * @brief This function returns a constant reference to member markers
 * @return Constant reference to member markers
 */
const std::vector<visualization_msgs::msg::Marker>& visualization_msgs::msg::MarkerArray::markers() const
{
    return m_markers;
}

/*!
 * @brief This function returns a reference to member markers
 * @return Reference to member markers
 */
std::vector<visualization_msgs::msg::Marker>& visualization_msgs::msg::MarkerArray::markers()
{
    return m_markers;
}


size_t visualization_msgs::msg::MarkerArray::getKeyMaxCdrSerializedSize(
        size_t current_alignment)
{
    static_cast<void>(current_alignment);
    return visualization_msgs_msg_MarkerArray_max_key_cdr_typesize;
}

bool visualization_msgs::msg::MarkerArray::isKeyDefined()
{
    return false;
}

void visualization_msgs::msg::MarkerArray::serializeKey(
        eprosima::fastcdr::Cdr& scdr) const
{
    (void) scdr;
}


