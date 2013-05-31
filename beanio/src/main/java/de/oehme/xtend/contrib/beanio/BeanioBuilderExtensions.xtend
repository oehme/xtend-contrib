package de.oehme.xtend.contrib.beanio

import org.beanio.builder.FieldBuilder
import org.beanio.builder.GroupBuilder
import org.beanio.builder.RecordBuilder
import org.beanio.builder.SegmentBuilder
import org.beanio.builder.StreamBuilder
import org.eclipse.xtext.xbase.lib.Procedures$Procedure1

class BeanioBuilderExtensions {

	def static addGroup(StreamBuilder builder, String recordName, Procedure1<? super GroupBuilder> groupInitializer) {
		builder.addGroup(new GroupBuilder(recordName) => groupInitializer)
	}

	def static addGroup(GroupBuilder builder, String recordName, Procedure1<? super GroupBuilder> recordInitializer) {
		builder.addGroup(new GroupBuilder(recordName) => recordInitializer)
	}

	def static addRecord(StreamBuilder builder, String recordName, Procedure1<? super RecordBuilder> recordInitializer) {
		builder.addRecord(new RecordBuilder(recordName) => recordInitializer)
	}

	def static addRecord(GroupBuilder builder, String recordName, Procedure1<? super RecordBuilder> recordInitializer) {
		builder.addRecord(new RecordBuilder(recordName) => recordInitializer)
	}

	def static addField(RecordBuilder builder, String fieldName, Procedure1<? super FieldBuilder> fieldInitializer) {
		builder.addField(new FieldBuilder(fieldName) => fieldInitializer)
	}

	def static addField(SegmentBuilder builder, String fieldName, Procedure1<? super FieldBuilder> fieldInitializer) {
		builder.addField(new FieldBuilder(fieldName) => fieldInitializer)
	}
}
