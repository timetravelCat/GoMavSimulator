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
 * @file Int64PubSubTypes.h
 * This header file contains the declaration of the serialization functions.
 *
 * This file was generated by the tool fastcdrgen.
 */


#ifndef _FAST_DDS_GENERATED_STD_MSGS_MSG_INT64_PUBSUBTYPES_H_
#define _FAST_DDS_GENERATED_STD_MSGS_MSG_INT64_PUBSUBTYPES_H_

#include <fastdds/dds/topic/TopicDataType.hpp>
#include <fastrtps/utils/md5.h>

#include "Int64.h"


#if !defined(GEN_API_VER) || (GEN_API_VER != 1)
#error \

    Generated Int64 is not compatible with current installed Fast DDS. Please, regenerate it with fastddsgen.
#endif  // GEN_API_VER

namespace std_msgs
{
    namespace msg
    {

        #ifndef SWIG
        namespace detail {

            template<typename Tag, typename Tag::type M>
            struct Int64_rob
            {
                friend constexpr typename Tag::type get(
                        Tag)
                {
                    return M;
                }
            };

            struct Int64_f
            {
                typedef int64_t Int64::* type;
                friend constexpr type get(
                        Int64_f);
            };

            template struct Int64_rob<Int64_f, &Int64::m_data>;

            template <typename T, typename Tag>
            inline size_t constexpr Int64_offset_of() {
                return ((::size_t) &reinterpret_cast<char const volatile&>((((T*)0)->*get(Tag()))));
            }
        }
        #endif

        /*!
         * @brief This class represents the TopicDataType of the type Int64 defined by the user in the IDL file.
         * @ingroup INT64
         */
        class Int64PubSubType : public eprosima::fastdds::dds::TopicDataType
        {
        public:

            typedef Int64 type;

            eProsima_user_DllExport Int64PubSubType();

            eProsima_user_DllExport virtual ~Int64PubSubType() override;

            eProsima_user_DllExport virtual bool serialize(
                    void* data,
                    eprosima::fastrtps::rtps::SerializedPayload_t* payload) override;

            eProsima_user_DllExport virtual bool deserialize(
                    eprosima::fastrtps::rtps::SerializedPayload_t* payload,
                    void* data) override;

            eProsima_user_DllExport virtual std::function<uint32_t()> getSerializedSizeProvider(
                    void* data) override;

            eProsima_user_DllExport virtual bool getKey(
                    void* data,
                    eprosima::fastrtps::rtps::InstanceHandle_t* ihandle,
                    bool force_md5 = false) override;

            eProsima_user_DllExport virtual void* createData() override;

            eProsima_user_DllExport virtual void deleteData(
                    void* data) override;

        #ifdef TOPIC_DATA_TYPE_API_HAS_IS_BOUNDED
            eProsima_user_DllExport inline bool is_bounded() const override
            {
                return true;
            }

        #endif  // TOPIC_DATA_TYPE_API_HAS_IS_BOUNDED

        #ifdef TOPIC_DATA_TYPE_API_HAS_IS_PLAIN
            eProsima_user_DllExport inline bool is_plain() const override
            {
                return is_plain_impl();
            }

        #endif  // TOPIC_DATA_TYPE_API_HAS_IS_PLAIN

        #ifdef TOPIC_DATA_TYPE_API_HAS_CONSTRUCT_SAMPLE
            eProsima_user_DllExport inline bool construct_sample(
                    void* memory) const override
            {
                new (memory) Int64();
                return true;
            }

        #endif  // TOPIC_DATA_TYPE_API_HAS_CONSTRUCT_SAMPLE

            MD5 m_md5;
            unsigned char* m_keyBuffer;

        private:

            static constexpr bool is_plain_impl()
            {
                return 8ULL == (detail::Int64_offset_of<Int64, detail::Int64_f>() + sizeof(int64_t));

            }};
    }
}

#endif // _FAST_DDS_GENERATED_STD_MSGS_MSG_INT64_PUBSUBTYPES_H_